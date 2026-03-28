variable "do_token" {
  description = "DigitalOcean API token"
  type        = string
  sensitive   = true
}

variable "region" {
  description = "DigitalOcean region where the droplet will be created"
  type        = string
  default     = "ams3"
}

variable "droplet_size" {
  description = "Slug for the droplet size (see: doctl compute size list)"
  type        = string
  default     = "s-1vcpu-1gb"
}

variable "droplet_image" {
  description = "Slug for the OS image (see: doctl compute image list --public). Ignored when snapshot_id is set."
  type        = string
  default     = "ubuntu-22-04-x64"
}

variable "snapshot_id" {
  description = "ID of a DigitalOcean snapshot to create the droplet from (leave empty to use droplet_image)"
  type        = string
  default     = ""
}

variable "droplet_name" {
  description = "Name for the droplet"
  type        = string
  default     = "my-server"
}

variable "ssh_key_fingerprint" {
  description = "Name of the SSH key registered in DigitalOcean"
  type        = string
}

variable "ansible_user" {
  description = "User Ansible will use to connect via SSH (after initial hardening)"
  type        = string
  default     = "deploy"
}

variable "ansible_ssh_private_key" {
  description = "Path to the local SSH private key for Ansible connections"
  type        = string
  default     = "~/.ssh/id_rsa"
}

variable "inventory_output_path" {
  description = "Path where the Ansible inventory file will be written"
  type        = string
  default     = "../ansible/inventory/hosts.ini"
}

variable "ssh_allowed_ips" {
  description = "List of IPs/CIDRs allowed to SSH into the droplet (default: unrestricted)"
  type        = list(string)
  default     = ["0.0.0.0/0", "::/0"]
}

variable "project_name" {
  description = "Name of the DigitalOcean project to assign the droplet to (leave empty to skip)"
  type        = string
  default     = ""
}

variable "tags" {
  description = "List of tags to assign to the droplet"
  type        = list(string)
  default     = ["terraform", "ansible"]
}
