#!/bin/bash

echo "Iniciando destrucción de infraestructura en Azure con Terraform"

echo "Mostrando recursos que se van a eliminar..."
terraform plan -destroy

echo ""
read -p "¿Estás seguro de que quieres eliminar todos los recursos? (yes/no): " confirm

if [ "$confirm" = "yes" ]; then
    echo "Eliminando recursos"
    terraform destroy -auto-approve
    
    if [ $? -eq 0 ]; then
        echo "Recursos eliminados"
    else
        echo "Error al eliminar los recursos"
        exit 1
    fi
else
    echo "Operación cancelada. No se eliminaron recursos."
fi
