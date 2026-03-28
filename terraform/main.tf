# Look up the SSH key registered in DO by its name
data "digitalocean_ssh_key" "default" {
  name = var.ssh_key_fingerprint
}

# Main droplet
resource "digitalocean_droplet" "main" {
  name     = var.droplet_name
  region   = var.region
  size     = var.droplet_size
  image    = var.snapshot_id != "" ? var.snapshot_id : var.droplet_image
  ssh_keys = [data.digitalocean_ssh_key.default.id]
  tags     = var.tags

  # Wait for the droplet to be ready before proceeding
  lifecycle {
    create_before_destroy = true
  }
}

# Basic firewall for the droplet
resource "digitalocean_firewall" "main" {
  name        = "${var.droplet_name}-firewall"
  droplet_ids = [digitalocean_droplet.main.id]

  # SSH — restricted to allowed IPs
  inbound_rule {
    protocol         = "tcp"
    port_range       = "22"
    source_addresses = var.ssh_allowed_ips
  }

  # HTTP
  inbound_rule {
    protocol         = "tcp"
    port_range       = "80"
    source_addresses = ["0.0.0.0/0", "::/0"]
  }

  # HTTPS
  inbound_rule {
    protocol         = "tcp"
    port_range       = "443"
    source_addresses = ["0.0.0.0/0", "::/0"]
  }

  # Allow all outbound traffic
  outbound_rule {
    protocol              = "tcp"
    port_range            = "1-65535"
    destination_addresses = ["0.0.0.0/0", "::/0"]
  }

  outbound_rule {
    protocol              = "udp"
    port_range            = "1-65535"
    destination_addresses = ["0.0.0.0/0", "::/0"]
  }

  outbound_rule {
    protocol              = "icmp"
    destination_addresses = ["0.0.0.0/0", "::/0"]
  }
}

# Assign droplet to a DO project (optional)
data "digitalocean_project" "target" {
  count = var.project_name != "" ? 1 : 0
  name  = var.project_name
}

resource "digitalocean_project_resources" "main" {
  count   = var.project_name != "" ? 1 : 0
  project = data.digitalocean_project.target[0].id
  resources = [
    digitalocean_droplet.main.urn
  ]
}

# Generate the Ansible inventory from the template
resource "local_file" "ansible_inventory" {
  content = templatefile("${path.module}/templates/inventory.tpl", {
    droplet_ip              = digitalocean_droplet.main.ipv4_address
    droplet_name            = var.droplet_name
    ansible_user            = var.ansible_user
    ansible_ssh_private_key = var.ansible_ssh_private_key
  })
  filename        = var.inventory_output_path
  file_permission = "0644"

  depends_on = [digitalocean_droplet.main]
}
