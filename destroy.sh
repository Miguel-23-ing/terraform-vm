#!/bin/bash

echo "Iniciando destrucción de infraestructura en Azure con Terraform"

echo "Mostrando recursos que se van a eliminar..."
terraform plan -destroy

echo ""
read -p "¿Estás seguro de que quieres eliminar todos los recursos? (yes/no): " confirm

if [ "$confirm" != "yes" ]; then
    echo "Operación cancelada. No se eliminaron recursos."
    exit 0
fi

echo "Eliminando recursos con Terraform..."
terraform destroy -auto-approve

if [ $? -ne 0 ]; then
    echo "rror al eliminar todos los recursos de una vez."
    echo "Intentando eliminar primero la VM..."
    terraform destroy -target=azurerm_linux_virtual_machine.vm -auto-approve

    echo "Reintentando eliminar el resto..."
    terraform destroy -auto-approve
fi

if [ $? -ne 0 ]; then
    echo "⚠️ Todavía hay errores. Verificando si la NIC existe..."
    NIC_NAME="nic-vm-terraform"
    RG_NAME="rg-vm-terraform"

    if az network nic show --name $NIC_NAME --resource-group $RG_NAME &> /dev/null; then
        echo "Forzando eliminación de la NIC: $NIC_NAME"
        az network nic delete --name $NIC_NAME --resource-group $RG_NAME
    fi
fi

echo "Proceso completado. Verifica en el portal de Azure que no haya recursos restantes."

