variable "prefix" {
  type = string
}

variable "resource_group_name" {
  type = string
}

variable "location" {
  type = string
}

variable "subnet_pe_id" {
  type        = string
  description = "ID of the PE subnet from networking module"
}

variable "private_dns_zone_ids" {
  type        = map(string)
  description = "Map of dns zone IDs from networking: keys = sql, blob, kv"
}

variable "sql_admin_user" {
  type    = string
  default = "sqladminuser"
}

variable "sql_admin_password" {
  type      = string
  sensitive = true
}

variable "tags" {
  type    = map(string)
  default = {}
}