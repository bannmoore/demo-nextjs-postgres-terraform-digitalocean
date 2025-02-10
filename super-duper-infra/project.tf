# https://registry.terraform.io/providers/digitalocean/digitalocean/latest/docs/resources/project
resource "digitalocean_project" "super_duper_project" {
  name        = "super-duper-project"
  description = "Project containing resources required to run the Super Duper application."
  environment = "development"
  purpose     = "Web Application"
  resources = [
    digitalocean_app.super_duper_app.urn,
    digitalocean_database_cluster.super_duper_postgres.urn,
    digitalocean_droplet.super_duper_jump_server.urn,
    digitalocean_volume.super_duper_jump_server_volume.urn
  ]
}
