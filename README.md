<<<<<<< HEAD
# terraform-vm
=======
# VM Terraform - Azure

Este proyecto despliega una máquina virtual económica en Azure usando Terraform.

## Características

- **VM Size**: Standard_B1s (la más económica)
- **OS**: Ubuntu 20.04 LTS
- **Usuario**: azureuser
- **Contraseña**: TerraformVM123!
- **Acceso**: SSH y RDP habilitados
- **Puertos abiertos**: 22 (SSH), 80 (HTTP), 443 (HTTPS), 3389 (RDP)

## Requisitos previos

1. Azure CLI instalado y configurado
2. Terraform instalado
3. Suscripción de Azure activa

## Despliegue

1. **Inicializar Terraform**:
   ```bash
   terraform init
   ```

2. **Planificar el despliegue**:
   ```bash
   terraform plan
   ```

3. **Aplicar la configuración**:
   ```bash
   terraform apply
   ```

4. **Obtener la IP pública**:
   ```bash
   terraform output public_ip_address
   ```

## Conexión a la VM

### SSH (Linux/macOS)
```bash
ssh azureuser@<IP_PUBLICA>
```

### PuTTY (Windows)
- Host: IP_PUBLICA
- Port: 22
- Username: azureuser
- Password: TerraformVM123!

### RDP (Windows)
- IP: IP_PUBLICA
- Port: 3389
- Username: azureuser
- Password: TerraformVM123!

## Costos estimados

La VM Standard_B1s cuesta aproximadamente:
- **$7.30 USD/mes** en East US
- **$0.0104 USD/hora**

## Servicios incluidos

- Nginx web server (accesible en http://IP_PUBLICA)
- Herramientas básicas: htop, curl, wget, git, unzip
- Firewall configurado (UFW)

## Destruir recursos

Para eliminar todos los recursos y evitar costos:
```bash
terraform destroy
```

## Archivos del proyecto

- `main.tf`: Configuración principal de recursos
- `variables.tf`: Variables de configuración
- `outputs.tf`: Outputs del despliegue
- `cloud-init.txt`: Script de inicialización de la VM

## Seguridad

⚠️ **IMPORTANTE**: Esta configuración es para pruebas. Para producción:
- Cambiar la contraseña por defecto
- Usar SSH keys en lugar de contraseñas
- Restringir acceso por IP
- Implementar Azure Key Vault para secretos
>>>>>>> b012615 (feat: Add first version of terraform vm)
