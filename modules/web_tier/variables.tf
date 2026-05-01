
variable "prefix" {
  type = string
}

variable "resource_group_name" {
  type = string
}

variable "location" {
  type = string
}

variable "subnet_web_id" {
  type = string
}

variable "admin_username" {
  type    = string
  default = "azureuser"
}

variable "ssh_public_key" {
  type = string
}

variable "app_private_ip" {
  type        = string
  description = "Private IP of the app tier VM (used as NGINX upstream)"
}

variable "tags" {
  type    = map(string)
  default = {}
}