# terraform-google-dokuwiki
Terraform module which deploys [DokuWiki](https://www.dokuwiki.org/dokuwiki) using Google Cloud Run and Compute Engine.

## Prerequisites

- Domain Verification: The base domain for DokuWiki access needs to be verified. For example, if wiki is being hosted on `wiki.example.com`, `example.com` needs to be verified.

    ```bash
    # Check verified domains
    gcloud domains list-user-verified

    # Verify if required
    gcloud domains verify BASE-DOMAIN

    ```


## Usage
```hcl
module "dokuwiki" {
  source  = "Tax-Automation-Group/dokuwiki/google"
  version = "1.0.2"
  project_id = "project-id"
  storage_bucket_name = "bucket-name"
  domain_name = "wiki.example.com"
  dns_managed_zone = "example-dot-com"
}
```

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.10.3 |
| <a name="requirement_google"></a> [google](#requirement\_google) | >= 6.23.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_google"></a> [google](#provider\_google) | >= 6.23.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [google_cloud_run_domain_mapping.dockuwiki_mapping](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/cloud_run_domain_mapping) | resource |
| [google_cloud_run_service_iam_member.allow_unauth](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/cloud_run_service_iam_member) | resource |
| [google_cloud_run_v2_service.dokuwiki_nginx_reverse_proxy](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/cloud_run_v2_service) | resource |
| [google_compute_address.dokuwiki_internal_static_ip](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_address) | resource |
| [google_compute_disk.dokuwiki_storage](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_disk) | resource |
| [google_compute_disk_resource_policy_attachment.dokuwiki_snapshot_policy_attachment](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_disk_resource_policy_attachment) | resource |
| [google_compute_instance.dokuwiki_container_vm](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_instance) | resource |
| [google_compute_resource_policy.dokuwiki_storage_policy](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_resource_policy) | resource |
| [google_dns_record_set.wiki_cname_record](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/dns_record_set) | resource |
| [google_service_account.dokuwiki_deployment_sa](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/service_account) | resource |
| [google_storage_bucket.dokuwiki_config](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/storage_bucket) | resource |
| [google_storage_bucket_iam_member.read_access](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/storage_bucket_iam_member) | resource |
| [google_storage_bucket_object.config_template](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/storage_bucket_object) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_cloud_run_cpu"></a> [cloud\_run\_cpu](#input\_cloud\_run\_cpu) | CPU limit for the Cloud Run service | `string` | `"1000m"` | no |
| <a name="input_cloud_run_memory"></a> [cloud\_run\_memory](#input\_cloud\_run\_memory) | Memory limit for the Cloud Run service | `string` | `"512Mi"` | no |
| <a name="input_dns_managed_zone"></a> [dns\_managed\_zone](#input\_dns\_managed\_zone) | DNS managed zone for the custom domain | `string` | n/a | yes |
| <a name="input_dokuwiki_image"></a> [dokuwiki\_image](#input\_dokuwiki\_image) | Docker image for dokuwiki | `string` | `"dokuwiki/dokuwiki:stable"` | no |
| <a name="input_dokuwiki_storage_disk_type"></a> [dokuwiki\_storage\_disk\_type](#input\_dokuwiki\_storage\_disk\_type) | Persistent Disk type for dokuwiki storage in GB | `string` | `"pd-balanced"` | no |
| <a name="input_domain_name"></a> [domain\_name](#input\_domain\_name) | Custom domain name for DokuWiki deployment. The domain needs to be a verified domain. Verify if required: gcloud domains verify BASE-DOMAIN | `string` | n/a | yes |
| <a name="input_max_snapshot_retention_days"></a> [max\_snapshot\_retention\_days](#input\_max\_snapshot\_retention\_days) | Maximum retention days for the docuwiki-storage snapshot | `number` | `7` | no |
| <a name="input_nginx_image"></a> [nginx\_image](#input\_nginx\_image) | Docker image for the Cloud Run service | `string` | `"nginx:stable"` | no |
| <a name="input_project_id"></a> [project\_id](#input\_project\_id) | Google Project ID | `string` | n/a | yes |
| <a name="input_region"></a> [region](#input\_region) | Region where resources will be created | `string` | `"us-east1"` | no |
| <a name="input_service_accoun_id"></a> [service\_accoun\_id](#input\_service\_accoun\_id) | Service account name for the VM instance and Cloud Run service | `string` | `"dokuwiki-deployment-sa"` | no |
| <a name="input_storage_bucket_name"></a> [storage\_bucket\_name](#input\_storage\_bucket\_name) | Globally unique bucket name to store nginx config template | `string` | n/a | yes |
| <a name="input_vm_disk_size"></a> [vm\_disk\_size](#input\_vm\_disk\_size) | Disk size for the VM instance in GB | `number` | `10` | no |
| <a name="input_vm_disk_type"></a> [vm\_disk\_type](#input\_vm\_disk\_type) | Disk type for the VM instance | `string` | `"pd-standard"` | no |
| <a name="input_vm_image"></a> [vm\_image](#input\_vm\_image) | Image for the VM instance | `string` | `"https://www.googleapis.com/compute/beta/projects/cos-cloud/global/images/cos-stable-113-18244-1-61"` | no |
| <a name="input_vm_machine_type"></a> [vm\_machine\_type](#input\_vm\_machine\_type) | Machine type for the VM instance | `string` | `"e2-micro"` | no |
| <a name="input_vpc_network"></a> [vpc\_network](#input\_vpc\_network) | VPC network for the resources | `string` | `"default"` | no |
| <a name="input_vpc_subnetwork"></a> [vpc\_subnetwork](#input\_vpc\_subnetwork) | VPC subnetwork for the resources | `string` | `"default"` | no |
| <a name="input_zone"></a> [zone](#input\_zone) | Zone where resources will be created | `string` | `"us-east1-c"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_cloud_run_service_url"></a> [cloud\_run\_service\_url](#output\_cloud\_run\_service\_url) | The URL of the Cloud Run service |
| <a name="output_dns_record_name"></a> [dns\_record\_name](#output\_dns\_record\_name) | The DNS record name for the custom domain |
| <a name="output_service_account_email"></a> [service\_account\_email](#output\_service\_account\_email) | The email of the service account used by the VM instance and Cloud Run service |
| <a name="output_storage_bucket_name"></a> [storage\_bucket\_name](#output\_storage\_bucket\_name) | The name of the storage bucket |
| <a name="output_vm_instance_ip"></a> [vm\_instance\_ip](#output\_vm\_instance\_ip) | The internal IP address of the VM instance |
| <a name="output_vm_instance_name"></a> [vm\_instance\_name](#output\_vm\_instance\_name) | The name of the VM instance |
<!-- END_TF_DOCS -->