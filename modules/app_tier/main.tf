
# NIC (no public IP)

resource "azurerm_network_interface" "nic" {
  name                = "nic-app-${var.prefix}"
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags

  ip_configuration {
    name                          = "internal"
    subnet_id                     = var.subnet_app_id
    private_ip_address_allocation = "Dynamic"
  }
}

# NGINX cloud-init

locals {
  app_cloud_init = <<-EOT
    #cloud-config
    package_update: true
    packages:
      - nginx
    write_files:
      - path: /var/www/html/index.json
        content: |
          {
            "tier": "app",
            "message": "API tier reached via private network only",
            "served_by": "nginx"
          }
      - path: /etc/nginx/sites-available/default
        content: |
          server {
            listen 8080 default_server;
            server_name _;
            root /var/www/html;

            location / {
              default_type application/json;
              try_files /index.json =404;
            }

            location /health {
              default_type application/json;
              return 200 '{"status":"ok"}';
            }
          }
    runcmd:
      - systemctl restart nginx
      - systemctl enable nginx
  EOT
}

# VM

resource "azurerm_linux_virtual_machine" "app" {
  name                            = "vm-app-${var.prefix}"
  resource_group_name             = var.resource_group_name
  location                        = var.location
  size = "Standard_D2s_v3"
  admin_username                  = var.admin_username
  network_interface_ids           = [azurerm_network_interface.nic.id]
  disable_password_authentication = true
  tags                            = var.tags

  admin_ssh_key {
    username   = var.admin_username
    public_key = var.ssh_public_key
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "latest"
  }

  custom_data = base64encode(local.app_cloud_init)
}
