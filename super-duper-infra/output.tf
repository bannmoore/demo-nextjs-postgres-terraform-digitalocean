output "database_url" {
  sensitive = true
  value     = digitalocean_database_cluster.super_duper_postgres.uri
}

output "jump_server_droplet_name" {
  value = digitalocean_droplet.super_duper_jump_server.name
}

output "jump_server_address" {
  value = digitalocean_droplet.super_duper_jump_server.ipv4_address
}

output "jump_server_ssh_private_key_path" {
  value = var.jump_server_ssh_key_path
}

output "jump_server_volume_path" {
  value = "/mnt/${replace(var.jump_server_volume_name, "-", "_")}"
}
