output "storage_bucket_name" {
  description = "The name of the storage bucket"
  value       = google_storage_bucket.dokuwiki_config.name
}

output "vm_instance_name" {
  description = "The name of the VM instance"
  value       = google_compute_instance.dokuwiki_container_vm.name
}

output "vm_instance_ip" {
  description = "The internal IP address of the VM instance"
  value       = google_compute_address.dokuwiki_internal_static_ip.address
}

output "cloud_run_service_url" {
  description = "The URL of the Cloud Run service"
  value       = google_cloud_run_v2_service.dokuwiki_nginx_reverse_proxy.uri
}

output "service_account_email" {
  description = "The email of the service account used by the VM instance and Cloud Run service"
  value       = google_service_account.dokuwiki_deployment_sa.email
}

output "dns_record_name" {
  description = "The DNS record name for the custom domain"
  value       = google_dns_record_set.wiki_cname_record.name
}