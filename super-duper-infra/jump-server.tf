# https://registry.terraform.io/providers/digitalocean/digitalocean/latest/docs/data-sources/ssh_key
resource "digitalocean_ssh_key" "super_duper_jump_server_ssh_key" {
  name       = "super-duper-jump-server-ssh-key"
  public_key = file("${var.jump_server_ssh_key_path}.pub")
}

# https://registry.terraform.io/providers/digitalocean/digitalocean/latest/docs/resources/droplet
resource "digitalocean_droplet" "super_duper_jump_server" {
  name     = "super-duper-jump-server"
  image    = "ubuntu-24-10-x64"
  region   = var.do_region
  size     = "s-1vcpu-512mb-10gb"
  ssh_keys = [digitalocean_ssh_key.super_duper_jump_server_ssh_key.fingerprint]
  vpc_uuid = digitalocean_vpc.super_duper_vpc.id
}

# https://registry.terraform.io/providers/digitalocean/digitalocean/latest/docs/resources/volume
resource "digitalocean_volume" "super_duper_jump_server_volume" {
  name                    = var.jump_server_volume_name
  region                  = var.do_region
  size                    = 10
  initial_filesystem_type = "ext4"
  description             = "Jump server for database management"
}

# https://registry.terraform.io/providers/digitalocean/digitalocean/latest/docs/resources/volume_attachment
resource "digitalocean_volume_attachment" "super_duper_jump_volume_attachment" {
  droplet_id = digitalocean_droplet.super_duper_jump_server.id
  volume_id  = digitalocean_volume.super_duper_jump_server_volume.id
}
