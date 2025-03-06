variable "project_id" {
  type        = string
  description = "Google Project ID"
}

variable "storage_bucket_name" {
  type        = string
  description = "Globally unique bucket name to store nginx config template"
}

variable "region" {
  type        = string
  description = "Region where resources will be created"
  default     = "us-east1"
}

variable "zone" {
  type        = string
  description = "Zone where resources will be created"
  default     = "us-east1-c"
}

variable "vm_machine_type" {
  type        = string
  description = "Machine type for the VM instance"
  default     = "e2-micro"
}

variable "vm_image" {
  type        = string
  description = "Image for the VM instance"
  default     = "https://www.googleapis.com/compute/beta/projects/cos-cloud/global/images/cos-stable-113-18244-1-61"
}

variable "vm_disk_size" {
  type        = number
  description = "Disk size for the VM instance in GB"
  default     = 10
}

variable "dokuwiki_storage_disk_type" {
  type        = string
  description = "Persistent Disk type for dokuwiki storage in GB"
  default     = "pd-balanced"
}

variable "vm_disk_type" {
  type        = string
  description = "Disk type for the VM instance"
  default     = "pd-standard"
}

variable "nginx_image" {
  type        = string
  description = "Docker image for the Cloud Run service"
  default     = "nginx:stable"
}

variable "service_accoun_id" {
  type        = string
  description = "Service account name for the VM instance and Cloud Run service"
  default     = "dokuwiki-deployment-sa"
}

variable "dokuwiki_image" {
  type        = string
  description = "Docker image for dokuwiki"
  default     = "dokuwiki/dokuwiki:stable"
}

variable "cloud_run_cpu" {
  type        = string
  description = "CPU limit for the Cloud Run service"
  default     = "1000m"
}

variable "cloud_run_memory" {
  type        = string
  description = "Memory limit for the Cloud Run service"
  default     = "512Mi"
}

variable "domain_name" {
  type        = string
  description = "Custom domain name for DokuWiki deployment. The domain needs to be a verified domain. Verify if required: gcloud domains verify BASE-DOMAIN"
}

variable "dns_managed_zone" {
  type        = string
  description = "DNS managed zone for the custom domain"
}

variable "max_snapshot_retention_days" {
  type        = number
  description = "Maximum retention days for the docuwiki-storage snapshot"
  default     = 7
}

variable "vpc_network" {
  type        = string
  description = "VPC network for the resources"
  default     = "default"
}

variable "vpc_subnetwork" {
  type        = string
  description = "VPC subnetwork for the resources"
  default     = "default"
}



