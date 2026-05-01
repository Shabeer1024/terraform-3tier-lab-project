locals {
  tags = {
    project     = "3tier-private-lab"
    owner       = "shabeer"
    environment = "lab"
    managed_by  = "terraform"
  }
}

module "networking" {
  source     = "./modules/networking"
  prefix     = var.prefix
  location   = var.location
  my_home_ip = var.my_home_ip
  tags       = local.tags
}

module "data_tier" {
  source               = "./modules/data_tier"
  prefix               = var.prefix
  resource_group_name  = module.networking.resource_group_name
  location             = module.networking.location
  subnet_pe_id         = module.networking.subnet_pe_id
  private_dns_zone_ids = module.networking.private_dns_zone_ids
  sql_admin_password   = var.sql_admin_password
  tags                 = local.tags
}

module "app_tier" {
  source              = "./modules/app_tier"
  prefix              = var.prefix
  resource_group_name = module.networking.resource_group_name
  location            = module.networking.location
  subnet_app_id       = module.networking.subnet_app_id
  ssh_public_key      = var.ssh_public_key
  tags                = local.tags
}

module "web_tier" {
  source              = "./modules/web_tier"
  prefix              = var.prefix
  resource_group_name = module.networking.resource_group_name
  location            = module.networking.location
  subnet_web_id       = module.networking.subnet_web_id
  ssh_public_key      = var.ssh_public_key
  app_private_ip      = module.app_tier.app_private_ip
  tags                = local.tags
}
