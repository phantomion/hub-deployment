variable "region" {
  description = "The Azure Region in which all resources should be created."
}

variable "prefix" {
  description = "Prefix for this setup instance to distiguish from other installs of the same thing"
}

variable "dns_zone" {
  description = "DNS Zone (dns domain/subdomain) for our DNS records"
}

variable "ssh_user_name" {
  description = "Username to use for SSH+sudo into VMs."
  default = "azure-user"
}

variable "ssh_public_key" {
  description = "SSH Public key to insert into VMs for sudo access to them. Ensure you have the private key for ansible to use."
}

variable "worker_vm_count" {
  description = "Number of worker vms"
  default = 2
}

variable "hubvmsize" {
  description = "Hub VM type"
  default = "Standard_DC4s_v3"
}

variable "workervmsize" {
  description = "Workbench VM type"
  default = "Standard_DC2s_v3"
}

variable "dbsku" {
  description = "Postgres Database Sku/type"
  default = "B_Standard_B2s"
}

variable "dbusername" {
  description = "DB username"
  default = "hubdb"
}

variable "dbpassword" {
  description = "DB password"
}

variable "acme_email" {
  description = "The Azure Region in which all resources should be created."
}

variable "acme_cert_password" {
  description = "A password is required for the pfx certificate"
  sensitive = true
}

variable "cloudflare_api_token" {
  description = "A cloudflare api token with read/write permissions for the hub dns zone"
  sensitive = true
}

variable "setup_from_address_range" {
  description = "IP addresses to open for SSH, so ansible can talk to the VMs for step 2. In the form of 10.20.30.40/24"
}

variable "create_ldap_example_vm" {
  description = "Create an example open ldap vm (not for production use)"
  default = false
}

variable "tags" {
  description = "Tags to be added to created resources (optional)"
  default = {}
}
