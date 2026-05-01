variable "prefix" {
    type = string
    description = "Prefix for resource naming, e.g. 3tlab"
}

variable "location" {
  type        = string
  description = "Azure region"
  default     = "uksouth"
}

variable "vnet_cidr" {
  type    = string
  default = "10.0.0.0/16"
}

variable "subnet_cidrs" {
  type = map(string)
  default = {
    web = "10.0.1.0/24"
    app = "10.0.2.0/24"
    pe  = "10.0.3.0/24"
  }
}


variable "my_home_ip" {
  type        = string
  description = "Your home public IP in CIDR (e.g. 49.207.10.5/32) for SSH whitelist"
}

variable "tags" {
  type    = map(string)
  default = {}
}