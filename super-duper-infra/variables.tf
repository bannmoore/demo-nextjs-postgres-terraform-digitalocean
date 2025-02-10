variable "do_region" {
  type    = string
  default = "sfo3"
}

# app expects a slightly different slug
variable "do_app_region" {
  type    = string
  default = "sfo"
}

variable "jump_server_ssh_key_path" {
  description = "Path to the SSH key used to access the Jump Server"
  type        = string
  default     = "~/.ssh/id_rsa"
}

# This is a variable because the digitalocean_volume resource will mount the volume
# onto the droplet in a directory of this name, with the dashes replaced by underscores.
# See output.tf for usage.
variable "jump_server_volume_name" {
  type    = string
  default = "super-duper-jump-server-volume"
}
