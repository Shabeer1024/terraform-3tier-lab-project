variable "prefix" {
  type = string
}

variable "resource_group_name" {
  type = string
}

variable "location" {
  type = string
}

variable "subnet_app_id" {
  type = string
}

variable "admin_username" {
  type    = string
  default = "azureuser"
}

variable "ssh_public_key" {
  type        = string
  description = "Contents of ~/.ssh/id_rsa.pub"
}

variable "tags" {
  type    = map(string)
  default = {}
}