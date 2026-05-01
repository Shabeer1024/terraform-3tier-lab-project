variable "prefix" {
  type    = string
  default = "3tlab"
}

variable "location" {
  type    = string
  default = "southeastasia"
}

variable "my_home_ip" {
  type        = string
  description = "Your home IP in CIDR e.g. 49.207.10.5/32"
}

variable "sql_admin_password" {
  type      = string
  sensitive = true
}

# Reserved for app_tier module (currently commented out)
variable "ssh_public_key" {
  type        = string
  description = "SSH public key for app/web tier VMs (used when those modules are uncommented)"
  default     = ""
}
