# https://registry.terraform.io/providers/digitalocean/digitalocean/latest/docs/resources/vpc
resource "digitalocean_vpc" "super_duper_vpc" {
  name   = "super-duper-network"
  region = var.do_region
}
