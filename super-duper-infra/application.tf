# https://registry.terraform.io/providers/digitalocean/digitalocean/latest/docs/resources/app
resource "digitalocean_app" "super_duper_app" {
  spec {
    name   = "super-duper-app"
    region = var.do_app_region

    alert {
      rule = "DEPLOYMENT_FAILED"
    }

    service {
      name               = "web"
      http_port          = 80
      instance_count     = 1
      instance_size_slug = "basic-xxs"

      image {
        registry_type = "DOCR"
        repository    = "super-duper-app"
        tag           = "latest"
        deploy_on_push {
          enabled = true
        }
      }

      env {
        key   = "DATABASE_URL"
        value = digitalocean_database_cluster.super_duper_postgres.uri
        type  = "SECRET"
      }

      env {
        key   = "DATABASE_CERT"
        value = "$${super-duper-database.CA_CERT}"
        type  = "SECRET"
      }
    }

    database {
      name         = "super-duper-database"
      cluster_name = digitalocean_database_cluster.super_duper_postgres.name
      db_name      = "defaultdb"
      db_user      = "doadmin"
      engine       = "PG"
      production   = true
    }
  }
}
