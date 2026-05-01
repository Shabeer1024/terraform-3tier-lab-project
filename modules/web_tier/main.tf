
resource "azurerm_public_ip" "pip" {
  name                = "pip-web-${var.prefix}"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"
  tags                = var.tags
}

resource "azurerm_network_interface" "nic" {
  name                = "nic-web-${var.prefix}"
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags

  ip_configuration {
    name                          = "external"
    subnet_id                     = var.subnet_web_id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.pip.id
  }
}

locals {
  web_cloud_init = <<-EOT
    #cloud-config
    package_update: true
    packages:
      - nginx
    write_files:
      - path: /etc/nginx/sites-available/default
        content: |
          server {
            listen 80 default_server;
            server_name _;
            location / {
              proxy_pass http://${var.app_private_ip}:8080;
              proxy_set_header Host $host;
              proxy_set_header X-Real-IP $remote_addr;
            }
          }
    runcmd:
      - systemctl restart nginx
      - systemctl enable nginx
  EOT
}

resource "azurerm_linux_virtual_machine" "web" {
  name                            = "vm-web-${var.prefix}"
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

  custom_data = base64encode(local.web_cloud_init)
}
