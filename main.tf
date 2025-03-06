# # Create new storage bucket in the US
# # location with Standard Storage

resource "google_storage_bucket" "dokuwiki_config" {
  name                        = var.storage_bucket_name
  location                    = "US"
  public_access_prevention    = "enforced"
  uniform_bucket_level_access = true
}

# # Upload a text file as an object
# # to the storage bucket

resource "google_storage_bucket_object" "config_template" {
  name         = "dokuwiki-nginx.conf.template"
  source       = "${path.module}/config/dokuwiki-nginx.conf.template"
  content_type = "text/plain"
  bucket       = google_storage_bucket.dokuwiki_config.name
}

resource "google_compute_address" "dokuwiki_internal_static_ip" {
  address_type = "INTERNAL"
  name         = "dokuwiki-internal-static-ip"
  network_tier = "PREMIUM"
  project      = var.project_id
  purpose      = "GCE_ENDPOINT"
  region       = var.region
  subnetwork   = var.vpc_subnetwork
}

resource "google_compute_resource_policy" "dokuwiki_storage_policy" {
  name   = "dokuwiki-storage-snapshot-policy"
  project = var.project_id
  region = var.region
  snapshot_schedule_policy {
    schedule {
      daily_schedule {
        days_in_cycle = 1
        start_time    = "15:00"
      }
    }
    retention_policy {
      max_retention_days = var.max_snapshot_retention_days
    }
  }
}

resource "google_compute_disk" "dokuwiki_storage" {
  name                      = "dokuwiki-storage"
  physical_block_size_bytes = 4096
  project                   = var.project_id
  size                      = var.vm_disk_size
  type                      = var.dokuwiki_storage_disk_type
  zone                      = var.zone
  lifecycle {
    prevent_destroy = true
  }
}

resource "google_compute_disk_resource_policy_attachment" "dokuwiki_snapshot_policy_attachment" {
  name = google_compute_resource_policy.dokuwiki_storage_policy.name
  disk = google_compute_disk.dokuwiki_storage.name
  zone = var.zone
}

resource "google_service_account" "dokuwiki_deployment_sa" {
  account_id   = var.service_accoun_id
  display_name = "DokuWiki Deployment Service Account"
  project      = var.project_id
}

resource "google_storage_bucket_iam_member" "read_access" {
  bucket = google_storage_bucket.dokuwiki_config.name
  role   = "roles/storage.objectViewer"
  member = "serviceAccount:${google_service_account.dokuwiki_deployment_sa.email}"
}

resource "google_compute_instance" "dokuwiki_container_vm" {
  attached_disk {
    device_name = "dokuwiki-storage"
    mode        = "READ_WRITE"
    source      = google_compute_disk.dokuwiki_storage.name
  }

  boot_disk {
    auto_delete = true
    device_name = "dokuwiki-container-vm"

    initialize_params {
      image = var.vm_image
      size  = var.vm_disk_size
      type  = var.vm_disk_type
    }

    mode = "READ_WRITE"
  }

  labels = {
    container-vm = "dokuwiki-container-vm"
  }

  machine_type = var.vm_machine_type

  metadata = {
    gce-container-declaration = jsonencode({
      spec = {
        restartPolicy = "Always"
        containers = [{
          name  = "dokuwiki-container"
          image = var.dokuwiki_image
          volumeMounts = [{
            name      = "pd-0"
            mountPath = "/storage"
            readOnly  = false
          }]
          securityContext = {
            privileged = false
          }
        }]
        volumes = [{
          name = "pd-0"
          gcePersistentDisk = {
            pdName   = google_compute_disk.dokuwiki_storage.name
            fsType   = "ext4"
            readOnly = false
          }
        }]
      }
    })
  }

  name = "dokuwiki-container-vm"

  network_interface {
    access_config {
      network_tier = "STANDARD"
    }
    network    = var.vpc_network
    network_ip = google_compute_address.dokuwiki_internal_static_ip.address
    stack_type = "IPV4_ONLY"
  }

  project = var.project_id

  reservation_affinity {
    type = "ANY_RESERVATION"
  }

  scheduling {
    automatic_restart   = true
    on_host_maintenance = "MIGRATE"
    provisioning_model  = "STANDARD"
  }

  service_account {
    email  = google_service_account.dokuwiki_deployment_sa.email
    scopes = ["https://www.googleapis.com/auth/cloud-platform"]
  }

  shielded_instance_config {
    enable_integrity_monitoring = true
    enable_vtpm                 = true
  }

  tags                      = ["http-server"]
  zone                      = var.zone
  allow_stopping_for_update = true
}

resource "google_cloud_run_v2_service" "dokuwiki_nginx_reverse_proxy" {
  client       = "cloud-console"
  ingress      = "INGRESS_TRAFFIC_ALL"
  launch_stage = "GA"
  location     = var.region
  name         = "dokuwiki-nginx-reverse-proxy"
  project      = var.project_id
  deletion_protection = false

  template {
    containers {
      args = ["nginx", "-c", "/etc/nginx/conf.d/dokuwiki-nginx.conf", "-g", "daemon off;"]

      env {
        name  = "DOKUWIKI_CONTAINER_VM_INTERNAL_STATIC_IP"
        value = google_compute_address.dokuwiki_internal_static_ip.address
      }

      image = var.nginx_image
      name  = "nginx-1"

      ports {
        container_port = 8080
        name           = "http1"
      }

      resources {
        cpu_idle = true

        limits = {
          cpu    = var.cloud_run_cpu
          memory = var.cloud_run_memory
        }

        startup_cpu_boost = true
      }

      startup_probe {
        failure_threshold     = 2
        initial_delay_seconds = 0
        period_seconds        = 60

        tcp_socket {
          port = 8080
        }

        timeout_seconds = 60
      }

      volume_mounts {
        mount_path = "/etc/nginx/templates/"
        name       = google_storage_bucket.dokuwiki_config.name
      }
    }

    max_instance_request_concurrency = 10

    scaling {
      max_instance_count = 1
    }

    service_account = google_service_account.dokuwiki_deployment_sa.email
    timeout         = "300s"

    volumes {
      name = google_storage_bucket.dokuwiki_config.name
      gcs {
        bucket    = google_storage_bucket.dokuwiki_config.name
        read_only = true
      }
    }

    vpc_access {
      egress = "PRIVATE_RANGES_ONLY"

      network_interfaces {
        network    = var.vpc_network
        subnetwork = var.vpc_subnetwork
      }
    }
  }

  traffic {
    type    = "TRAFFIC_TARGET_ALLOCATION_TYPE_LATEST"
    percent = 100
  }
}

resource "google_cloud_run_service_iam_member" "allow_unauth" {
  service  = google_cloud_run_v2_service.dokuwiki_nginx_reverse_proxy.name
  location = google_cloud_run_v2_service.dokuwiki_nginx_reverse_proxy.location
  role     = "roles/run.invoker"
  member   = "allUsers"
}

resource "google_cloud_run_domain_mapping" "dockuwiki_mapping" {
  location = var.region
  name     = var.domain_name
  project  = var.project_id

  metadata {
    namespace = var.project_id
  }

  spec {
    route_name = google_cloud_run_v2_service.dokuwiki_nginx_reverse_proxy.name
  }
}


resource "google_dns_record_set" "wiki_cname_record" {
  name         = "${var.domain_name}."
  type         = "CNAME"
  ttl          = 300
  managed_zone = var.dns_managed_zone
  project      = var.project_id

  rrdatas    = ["ghs.googlehosted.com."]
  depends_on = [google_cloud_run_domain_mapping.dockuwiki_mapping]
}