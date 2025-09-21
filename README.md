# VM Terraform - Azure

This project provisions an affordable Azure virtual machine using Terraform, with automated setup via cloud-init and secured with SSH key authentication.

## Features

- **VM Size**: Standard_B1s (most economical)
- **OS**: Ubuntu 20.04 LTS
- **Username**: azureuser
- **Authentication**: SSH Keys (auto-generated)
- **Access**: SSH enabled with key-based authentication
- **Open ports**: 22 (SSH), 80 (HTTP), 443 (HTTPS)
- **Pre-installed software**: Nginx, htop, curl, wget, git, unzip, fail2ban, UFW
- **Web server**: Nginx with custom welcome page
- **Architecture**: Modular design with separate networking, security, and compute modules

## Prerequisites

- Azure CLI installed and configured
- Terraform installed (version 1.0 or higher)
- Active Azure subscription
- Bash shell (for scripts)

## Project Structure

```
.
├── main.tf                    # Main Terraform configuration
├── variables.tf               # Variable definitions
├── outputs.tf                 # Output definitions
├── terraform.tfvars.example  # Example configuration file
├── cloud-init.txt            # VM initialization script
├── deploy.sh                 # Automated deployment script
├── destroy.sh                # Resource cleanup script
└── modules/
    ├── networking/
    │   ├── main.tf           # VNet, subnet, public IP
    │   ├── variables.tf      # Networking variables
    │   └── outputs.tf        # Networking outputs
    ├── security/
    │   ├── main.tf           # Network Security Group
    │   ├── variables.tf      # Security variables
    │   └── outputs.tf        # Security outputs
    └── compute/
        ├── main.tf           # VM, NIC, storage
        ├── variables.tf      # Compute variables
        └── outputs.tf        # Compute outputs
```

## Configuration

### Step 1: Configure Variables

Copy the example file and configure your settings:

```bash
cp terraform.tfvars.example terraform.tfvars
```

Edit `terraform.tfvars` with your Azure subscription ID:

```hcl
# ⚠️ REQUIRED: Replace with your Azure subscription ID
subscription_id = "your-subscription-id-here"

# Basic configuration
resource_group_name = "rg-vm-terraform"
location           = "East US"
vm_name            = "vm-terraform-miguel"
admin_username     = "azureuser"

# VM optimized for student plan
vm_size = "Standard_B1s"  # Most economical
```

### Step 2: Configure SSH Access (Optional)

For enhanced security, restrict SSH access to your IP:

```hcl
# In terraform.tfvars
allowed_ssh_sources = ["YOUR_PUBLIC_IP/32"]  # Replace with your IP
```

Get your public IP:
```bash
curl ifconfig.me
```

## Architecture Overview

### Modular Design

The project uses a modular architecture for better organization and reusability:

#### 1. **Networking Module** (`modules/networking/`)
- Virtual Network (VNet): 10.0.0.0/16
- Subnet: 10.0.2.0/24
- Public IP with static allocation
- Standard SKU for load balancer compatibility

#### 2. **Security Module** (`modules/security/`)
- Network Security Group (NSG)
- Security rules for SSH (22), HTTP (80), HTTPS (443)
- Configurable source IP restrictions

#### 3. **Compute Module** (`modules/compute/`)
- Linux Virtual Machine (Ubuntu 20.04 LTS)
- Network Interface with dynamic private IP
- Standard_LRS storage account for diagnostics
- SSH key-based authentication
- Cloud-init integration

## Deployment

![Terraform Init and Plan](image-6.png)

![Terraform Apply](image-7.png)

### Option A: Automated Deployment

Make scripts executable and run:

```bash
chmod +x ./deploy.sh ./destroy.sh
./deploy.sh
```

### Option B: Manual Deployment

#### Initialize Terraform:
```bash
terraform init
```

#### Plan the deployment:
```bash
terraform plan
```

#### Apply the configuration:
```bash
terraform apply
```

#### Get the public IP:
```bash
terraform output public_ip_address
```

## SSH Connection

The project automatically generates SSH key pairs for secure access.

### Get Connection Details:
```bash
terraform output ssh_connection_command
```

### Connect to VM:
```bash
ssh -i ssh-key-vm-terraform-miguel.pem azureuser@<PUBLIC_IP>
```

### Key Files Generated:
- `ssh-key-{vm_name}.pem` - Private key (keep secure)
- Public key is automatically deployed to the VM

![Deployment Success](image-9.png)

![Resource Cleanup](image-10.png)

## Web Access

Once deployed, access the web server at:
```
http://<PUBLIC_IP>
```

## Infrastructure Components

Based on your deployment, the infrastructure includes:

- **Resource Group**: rg-vm-terraform
- **Virtual Machine**: vm-terraform-miguel
- **Network Interface**: nic-vm-terraform-miguel
- **Public IP**: pip-vm-terraform
- **Virtual Network**: vnet-vm-terraform
- **Subnet**: subnet-vm-terraform
- **Network Security Group**: nsg-vm-terraform
- **Storage Account**: diagstorage{random} (for boot diagnostics)

## Estimated Costs

The Standard_B1s VM costs approximately:
- **$7.30 USD/month** in East US
- **$0.0104 USD/hour**
- Perfect for Azure Student Plan

## Security Features

### ✅ Implemented Security Measures:
- **SSH Key Authentication**: No passwords, only cryptographic keys
- **Firewall Configuration**: UFW enabled with specific rules
- **Fail2Ban**: SSH brute-force protection
- **No Root Login**: Root access disabled
- **Network Security Groups**: Azure-level firewall rules
- **Security Updates**: Automatic package updates

### ⚠️ For Production Use:
- Change `allowed_ssh_sources` from `["0.0.0.0/0"]` to your specific IP
- Use Azure Key Vault for secret management
- Enable Azure Security Center
- Implement backup strategies
- Use Azure Bastion for secure access

## Cloud-Init Configuration

The [`cloud-init.txt`](cloud-init.txt) file automatically configures:

1. **System Updates**: Updates all packages
2. **Package Installation**: Installs nginx, htop, curl, wget, git, unzip, fail2ban, ufw
3. **User Configuration**: Sets up azureuser with sudo privileges
4. **SSH Hardening**: Disables password auth, configures secure SSH
5. **Firewall Setup**: Configures UFW with SSH, HTTP, HTTPS rules
6. **Web Server**: Installs and configures Nginx with custom page
7. **Security Services**: Enables and starts fail2ban

## Bash Scripts

### [`deploy.sh`](deploy.sh)
- Validates prerequisites (Terraform, Azure CLI)
- Checks Azure authentication
- Runs terraform init, plan, and apply
- Displays connection information
- Provides cost estimates

### [`destroy.sh`](destroy.sh)
- Shows resources to be deleted
- Requires confirmation
- Handles cleanup gracefully
- Removes temporary files

## Outputs

After deployment, you'll get:

```bash
terraform output
```

Available outputs:
- `public_ip_address` - VM's public IP
- `ssh_connection_command` - Ready-to-use SSH command
- `web_url` - HTTP URL to web server
- `vm_admin_username` - Username for SSH
- `vm_size` - Deployed VM size
- `vm_location` - Azure region
- `estimated_monthly_cost` - Cost information

## Troubleshooting

### SSH Connection Issues
1. Verify VM is running: Check Azure Portal
2. Test connectivity: `ping <PUBLIC_IP>`
3. Check SSH key permissions: `chmod 600 ssh-key-*.pem`
4. Verify NSG rules allow your IP

### Web Server Issues
1. SSH into VM and check nginx: `sudo systemctl status nginx`
2. Check firewall: `sudo ufw status`
3. Test locally: `curl http://localhost` (from VM)

### Terraform Issues
1. Check subscription permissions
2. Verify terraform.tfvars configuration
3. Run `terraform validate` for syntax errors
4. Check Azure resource quotas

## Cleanup

⚠️ **Important**: Always destroy resources when not needed to avoid charges.

### Automated Cleanup:
```bash
./destroy.sh
```

### Manual Cleanup:
```bash
terraform destroy
```

This will remove:
- Virtual Machine
- Network components
- Storage accounts
- Resource group (if empty)
- Generated SSH keys

## File Descriptions

### Core Files:
- **[`main.tf`](main.tf)**: Main configuration with module calls
- **[`variables.tf`](variables.tf)**: All configurable parameters
- **[`outputs.tf`](outputs.tf)**: Information displayed after deployment
- **[`terraform.tfvars.example`](terraform.tfvars.example)**: Configuration template

### Module Files:
- **[`modules/networking/`](modules/networking/)**: Network infrastructure
- **[`modules/security/`](modules/security/)**: Security groups and rules
- **[`modules/compute/`](modules/compute/)**: Virtual machine and related resources

### Automation Files:
- **[`cloud-init.txt`](cloud-init.txt)**: VM initialization script
- **[`deploy.sh`](deploy.sh)**: Automated deployment
- **[`destroy.sh`](destroy.sh)**: Automated cleanup

### Generated Files:
- `ssh-key-*.pem` - Private SSH key (excluded from git)
- `.terraform/` - Terraform working directory
- `terraform.tfstate` - Infrastructure state
- `tfplan` - Deployment plan

## Best Practices Implemented

1. **Modular Architecture**: Separated concerns for maintainability
2. **Variable Validation**: Ensures correct VM sizes for student plan
3. **SSH Key Generation**: Automatic secure key creation
4. **Cost Optimization**: Uses cheapest Azure VM options
5. **Security Hardening**: Multiple layers of security
6. **Documentation**: Comprehensive README and code comments
7. **Automation**: Scripts for common operations
8. **Error Handling**: Graceful failure management

## Contributing

This project is designed for educational purposes. Feel free to:
- Fork and modify for your needs
- Submit improvements via pull requests
- Report issues or suggest enhancements
- Use as a learning resource for Terraform and Azure

