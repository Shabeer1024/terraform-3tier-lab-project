# 🔒 Azure 3-Tier Architecture with Private Endpoints

> **Production-grade modular Terraform deployment of a 3-tier web application on Azure, where the data layer has zero public attack surface.**

[![Terraform](https://img.shields.io/badge/Terraform-1.5+-7B42BC?style=for-the-badge&logo=terraform&logoColor=white)](https://www.terraform.io/)
[![Azure](https://img.shields.io/badge/Microsoft_Azure-0078D4?style=for-the-badge&logo=microsoft-azure&logoColor=white)](https://azure.microsoft.com/)
[![License](https://img.shields.io/badge/License-MIT-green.svg?style=for-the-badge)](LICENSE)
[![NGINX](https://img.shields.io/badge/NGINX-009639?style=for-the-badge&logo=nginx&logoColor=white)](https://nginx.org/)
[![Made with Love](https://img.shields.io/badge/Made_with-❤️-red.svg?style=for-the-badge)](https://github.com/Shabeer1024)

---

## 🎯 Overview

This repository deploys a **complete 3-tier web application architecture** in Azure using modular Terraform, demonstrating enterprise-grade security patterns required by regulated industries (banking, healthcare, government).

The data tier — Azure SQL, Storage, and Key Vault — has **public network access completely disabled** and is only reachable through Private Endpoints inside a VNet. 

### What gets deployed

- **32 Azure resources** in ~7 minutes via a single `terraform apply`
- **3 subnets** (web, app, private endpoints) with tier-isolation NSGs
- **3 Private Endpoints** routing PaaS traffic over Azure backbone
- **3 Private DNS zones** with auto-registered A-records
- **2 Linux VMs** (NGINX) implementing the web/app tier reverse proxy chain
- **3 PaaS services** (SQL, Storage, Key Vault) with `public_network_access_enabled = false`

---

### Network layout

```
vnet-3tlab (10.0.0.0/16)
│
├── snet-web (10.0.1.0/24)        ← Web tier (public-facing NGINX)
│   └── vm-web-3tlab               (Public IP: <azure-assigned>)
│
├── snet-app (10.0.2.0/24)        ← App tier (private-only NGINX API)
│   └── vm-app-3tlab               (Private IP only — 10.0.2.4)
│
└── snet-pe  (10.0.3.0/24)        ← Private Endpoints subnet
    ├── pe-sql-3tlab    → 10.0.3.6 → Azure SQL Database
    ├── pe-blob-3tlab   → 10.0.3.5 → Storage Account
    └── pe-kv-3tlab     → 10.0.3.4 → Key Vault
```

### Traffic flow

```
[Internet User]
      │
      │ HTTPS
      ▼
[Web VM Public IP] ─── snet-web (NGINX reverse proxy)
      │
      │ Private VNet traffic
      ▼
[App VM Private IP 10.0.2.4] ─── snet-app (NGINX API)
      │
      │ Private DNS resolves FQDNs to 10.0.3.x
      ▼
[Private Endpoints in snet-pe]
      │
      │ Azure backbone (never touches internet)
      ▼
[Azure SQL] [Storage] [Key Vault]
```

---

## 🛡️ Why This Pattern Matters

### The compliance problem

In banking, healthcare, or any regulated industry, you **cannot** have customer data in a database with a public IP — even if it's "firewalled" or password-protected. Compliance auditors require **architectural isolation**, not just access control.

### Common (wrong) approaches

| Approach | Problem |
|---|---|
| "Use a strong firewall" | DB still has a public IP and DNS entry |
| "Service Endpoints" | Source IP is from VNet, but traffic still uses public DNS |
| "Allow only Azure services" | Doesn't satisfy strict compliance audits |

### The right pattern (this repo)

✅ **Private Endpoint** injects a NIC with a private IP into your VNet  
✅ **`public_network_access_enabled = false`** on every PaaS service  
✅ **Private DNS zones** intercept FQDN resolution and return private IPs  
✅ Traffic routes over Azure backbone — **never touches the internet**

---

## 📁 Project Structure

```
terraform-3tier-private-lab/
│
├── main.tf                    # Root module — orchestrates 4 child modules
├── providers.tf               # Azure provider configuration
├── variables.tf               # Input variables
├── outputs.tf                 # Useful outputs (IPs, FQDNs)
├── terraform.tfvars.example   # Sample tfvars (commit this, not the real one)
├── .gitignore                 # Excludes .tfstate, .tfvars, .terraform/
│
├── modules/
│   ├── networking/            # VNet, subnets, NSGs, Private DNS zones
│   ├── data_tier/             # SQL, Storage, KV + Private Endpoints
│   ├── app_tier/              # App VM + NIC + cloud-init NGINX
│   └── web_tier/              # Web VM + Public IP + NGINX reverse proxy
│
├── docs/
│   └── images/                # Architecture diagram + Portal screenshots
│
└── README.md
```

---

## ✅ Prerequisites

| Tool | Version | Install |
|---|---|---|
| **Terraform** | ≥ 1.5 | [Download](https://www.terraform.io/downloads) |
| **Azure CLI** | ≥ 2.50 | [Download](https://docs.microsoft.com/cli/azure/install-azure-cli) |
| **Active Azure subscription** | Free tier works (with VM SKU caveats) | [Sign up](https://azure.microsoft.com/free/) |
| **SSH key pair** | RSA 4096 (passphraseless for automation) | `ssh-keygen -t rsa -b 4096 -N ""` |

### Azure permissions required

- `Contributor` role on the target subscription (or resource group)
- `User Access Administrator` if you plan to assign RBAC (optional for this lab)

---

## 🚀 Quick Start

### 1. Clone the repository

```bash
git clone https://github.com/Shabeer1024/terraform-3tier-private-lab.git
cd terraform-3tier-private-lab
```

### 2. Authenticate to Azure

```bash
az login
az account set --subscription "<your-subscription-id>"
```

### 3. Configure your variables

Copy the example tfvars file and edit:

```bash
cp terraform.tfvars.example terraform.tfvars
```

Edit `terraform.tfvars`:

```hcl
prefix              = "3tlab"
location            = "southeastasia"
my_home_ip          = "X.X.X.X/32"          # Your public IPv4 (curl -4 ifconfig.me)
sql_admin_password  = "ChangeMe!Strong@2026"
ssh_public_key      = "ssh-rsa AAAA..."     # Paste contents of ~/.ssh/id_rsa.pub
vm_admin_password   = "ChangeMe!VM@2026"
```

> ⚠️ **Never commit `terraform.tfvars`** — it's already in `.gitignore`.

### 4. Initialize and deploy

```bash
terraform init
terraform validate
terraform plan -out=main.tfplan
terraform apply main.tfplan
```

Deploy time: **~7 minutes** (SQL Server is the slow resource).

### 5. Capture outputs

```bash
terraform output
```

Expected output:
```
app_private_ip       = "10.0.2.4"
key_vault_uri        = "https://kv-3tlab-xxxxxx.vault.azure.net/"
resource_group_name  = "rg-3tlab"
sql_fqdn             = "sql-3tlab-xxxxxx.database.windows.net"
ssh_to_web           = "ssh azureuser@<public-ip>"
storage_blob_endpoint = "https://st3tlabxxxxxx.blob.core.windows.net/"
web_public_ip        = "X.X.X.X"
```

---

## 🧪 Verification Tests

### Test 1 — End-to-end 3-tier chain

From your laptop:
```bash
curl http://<web_public_ip>
```

Expected:
```json
{
  "tier": "app",
  "message": "API tier reached via private network only",
  "served_by": "nginx"
}
```

✅ Proves: `Internet → Web VM → App VM → JSON response` chain works.

### Test 2 — Private DNS resolution from inside the VNet

SSH into the web VM:
```bash
ssh azureuser@<web_public_ip>
```

Then run:
```bash
nslookup sql-3tlab-xxxxxx.database.windows.net
nslookup st3tlabxxxxxx.blob.core.windows.net
nslookup kv-3tlab-xxxxxx.vault.azure.net
```

Expected (for each):
```
canonical name = sql-3tlab-xxxxxx.privatelink.database.windows.net.
Address: 10.0.3.6
```

✅ Proves: Private DNS zones intercept resolution and return PE private IPs.

### Test 3 — Public access blocked

From your laptop (outside the VNet):
```bash
curl "https://st3tlabxxxxxx.blob.core.windows.net/appdata?restype=container&comp=list"
```

Expected: `403 PublicAccessNotPermitted` or `AuthorizationFailure`

✅ Proves: PaaS services reject all traffic from outside the VNet.

### Test 4 — VNet-internal traffic

From the web VM:
```bash
curl http://10.0.2.4:8080
```

Expected: Same JSON as Test 1.

✅ Proves: Private network communication works between tiers.

---

## ⚙️ How It Works

### The Private DNS magic

When you create a Private Endpoint with this Terraform block:

```hcl
resource "azurerm_private_endpoint" "sql" {
  name                = "pe-sql-${var.prefix}"
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = var.pe_subnet_id

  private_service_connection {
    name                           = "psc-sql"
    private_connection_resource_id = azurerm_mssql_server.sql.id
    subresource_names              = ["sqlServer"]
    is_manual_connection           = false
  }

  private_dns_zone_group {
    name                 = "dns-zone-group-sql"
    private_dns_zone_ids = [var.private_dns_zone_id_sql]
  }
}
```

Three things happen automatically:
1. A NIC is created in `snet-pe` with a private IP (e.g., `10.0.3.6`)
2. An A-record is registered in `privatelink.database.windows.net` linking the SQL server name to that private IP
3. Any DNS query from inside the VNet now resolves the SQL FQDN to the private IP

### Why public IPs on the web VM don't break PE access

A common misconception: *"If my VM has a public IP, it can't use Private Endpoints."*

**Wrong.** Public IP and Private Endpoint access are **orthogonal**:
- **Public IP** = inbound NAT mapping (Internet → VM)
- **Private Endpoint** = outbound routing (VM → PaaS via VNet)

These flows never overlap. The web VM in this lab has both — and reaches PaaS via PEs without issue.

---

## 📚 Lessons Learned

These came from real deployment friction — they're not in most tutorials.

### 1. `private_endpoint_network_policies = "Disabled"` is mandatory
Without this on the PE subnet, `terraform apply` fails with a cryptic policy violation error.

```hcl
resource "azurerm_subnet" "pe" {
  name                                       = "snet-pe"
  address_prefixes                           = ["10.0.3.0/24"]
  private_endpoint_network_policies          = "Disabled"  # ← Required
}
```

### 2. Free-tier VM SKU capacity is unpredictable
Hit `SkuNotAvailable` errors for `Standard_B1s` across UK South, Central India, and Southeast Asia. Modular Terraform made the swap to `Standard_D2s_v3` a 2-line edit.

### 3. Private DNS zones must be VNet-linked BEFORE Private Endpoints
Order matters. If the PE is created before the zone link exists, auto-registration silently fails. Use Terraform output dependencies to enforce ordering:

```hcl
depends_on = [azurerm_private_dns_zone_virtual_network_link.sql]
```

### 4. Public DNS still resolves for blocked PaaS — blocking is at the data plane
Even with `public_network_access_enabled = false`, the storage account FQDN resolves via public DNS to a public IP. The 403 happens at the data operation layer, not at DNS or TCP. This is by design.

### 5. IPv6 vs IPv4 NSG mismatch
`curl ifconfig.me` may return IPv6, which doesn't match IPv4 NSG `source_address_prefix`. Always use `curl -4` to force IPv4.

---

## 🧹 Cleanup

**Always destroy lab resources** when done — VMs cost money even when idle.

```bash
terraform destroy -auto-approve
```

Destroy time: **~5–7 minutes** (Key Vault soft-delete is the slow part).

To avoid soft-delete blocking re-deploys, the provider config sets:

```hcl
provider "azurerm" {
  features {
    key_vault {
      purge_soft_delete_on_destroy    = true
      recover_soft_deleted_key_vaults = true
    }
  }
}
```

---

## 🗺️ Roadmap

Future enhancements I'm considering:

- [ ] **Azure Monitor + Log Analytics** for VM and PaaS observability
- [ ] **Azure DevOps Pipelines** for CI/CD of infrastructure
- [ ] **Azure Bastion** to replace public IP on web VM (production pattern)
- [ ] **Azure Application Gateway WAF** in front of the web tier
- [ ] **Multi-region deployment** with Azure Traffic Manager for DR
- [ ] **GitHub Actions** workflow for `terraform plan` on PRs
- [ ] **Azure Policy** enforcement (deny resources without PEs)
- [ ] **Terraform Cloud** remote state with state locking

---

## 📸 Screenshots

Visual proof of the deployment in action — see [`docs/images/`](docs/images/) for the full set:

- Architecture diagram (dark theme)
- Terraform apply success (32 resources)
- Resource Group with all 32 resources
- VNet subnets layout
- Private Endpoints list with private IPs
- NSG rules (web tier)
- SQL / Storage / Key Vault networking blades (public access disabled)
- Private DNS zones with auto-registered A-records
- `nslookup` from inside the VNet showing 10.0.3.x resolution
- `curl` test showing 3-tier chain returning JSON
- Az CLI verification of DNS records
- Terraform destroy clean-up

---

## 👤 Author

**Shabeer S**  
Azure Cloud Enthusiast ☁️ | CloudOps  | Exploring Azure Administration | AVD Specialist | AZ-700 | AZ-140 | Terraform | Azure Networking | Modern Workspace | ITIL V4 | 
🔗 [LinkedIn](https://linkedin.com/in/shabeer1024) | 🐙 [GitHub](https://github.com/Shabeer1024)

### Background
- 13+ years in enterprise IT, currently supporting a UAE-based banking client
- Azure certifications: AZ-140, AZ-700, ITIL V4
- Pursuing: AZ-305, HashiCorp Terraform Associate
- Focus areas: Azure landing zones, identity-governed automation, secure cloud networking

---

## 📜 License

This project is licensed under the MIT License — Free

---

## ⭐ Acknowledgments

Built with patience, real Azure capacity errors, and a strong belief that infrastructure code should be as reviewable as application code.

If this helped you understand Private Endpoints, **star the repo** ⭐ — it helps others find it.

---

> 