# https://registry.terraform.io/providers/digitalocean/digitalocean/latest/docs/resources/database_cluster
resource "digitalocean_database_cluster" "super_duper_postgres" {
  name                 = "super-duper-postgres"
  engine               = "pg"
  version              = "17"
  size                 = "db-s-1vcpu-1gb"
  region               = var.do_region
  node_count           = 1
  private_network_uuid = digitalocean_vpc.super_duper_vpc.id
}

# https://registry.terraform.io/providers/digitalocean/digitalocean/latest/docs/resources/database_firewall
resource "digitalocean_database_firewall" "super_duper_postgres_firewall" {
  cluster_id = digitalocean_database_cluster.super_duper_postgres.id

  rule {
    type  = "droplet"
    value = digitalocean_droplet.super_duper_jump_server.id
  }

  rule {
    type  = "app"
    value = digitalocean_app.super_duper_app.id
  }
}

