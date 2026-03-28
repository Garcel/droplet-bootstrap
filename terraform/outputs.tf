output "droplet_id" {
  description = "ID of the created droplet"
  value       = digitalocean_droplet.main.id
}

output "droplet_ip" {
  description = "Public IPv4 address of the droplet"
  value       = digitalocean_droplet.main.ipv4_address
}

output "droplet_urn" {
  description = "URN of the created droplet"
  value       = digitalocean_droplet.main.urn
}

output "droplet_name" {
  description = "Name of the droplet"
  value       = digitalocean_droplet.main.name
}

output "droplet_region" {
  description = "Region where the droplet was created"
  value       = digitalocean_droplet.main.region
}

output "droplet_image" {
  description = "Image used for the droplet"
  value       = digitalocean_droplet.main.image
}

output "ansible_inventory_path" {
  description = "Path where the Ansible inventory file was written"
  value       = local_file.ansible_inventory.filename
}

output "ssh_private_key_path" {
  description = "Path to the SSH private key used for connections"
  value       = var.ansible_ssh_private_key
}

output "ssh_connection" {
  description = "SSH command to connect to the droplet"
  value       = "ssh -i ${var.ansible_ssh_private_key} ${var.ansible_user}@${digitalocean_droplet.main.ipv4_address}"
  sensitive   = true
}
