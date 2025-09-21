#!/bin/bash

echo "Iniciando despliegue de infraestructura en Azure con Terraform"

# Verificar Terraform
if ! command -v terraform &> /dev/null; then
    echo "Terraform no está instalado. Instálalo primero."
    exit 1
fi

# Verificar Azure CLI
if ! command -v az &> /dev/null; then
    echo "Azure CLI no está instalado. Instálalo primero."
    exit 1
fi

# Verificar login en Azure
if ! az account show &> /dev/null; then
    echo "No estás logueado en Azure. Ejecuta 'az login' primero."
    exit 1
fi

echo "Inicializando Terraform."
if ! terraform init; then
    echo "Error al inicializar Terraform"
    exit 1
fi

echo "Creando plan de despliegue de Terraform"
if ! terraform plan -out=tfplan; then
    echo "Error al crear el plan de despliegue de Terraform"
    exit 1
fi

echo "Aplicando configuración de Terraform"
if ! terraform apply -auto-approve tfplan; then
    echo "Error al aplicar la configuración de Terraform"
    exit 1
fi

echo ""
echo "Despliegue completado exitosamente!"
echo ""
echo "Detalles de la VM:"
echo "-------------------"
echo "IP Pública:   $(terraform output -raw public_ip_address)"
echo "Usuario:      $(terraform output -raw vm_admin_username)"
echo "SSH comando:  $(terraform output -raw ssh_connection_command)"
echo "Tamaño VM:    $(terraform output -raw vm_size)"
echo "Ubicación:    $(terraform output -raw vm_location)"

echo ""
echo "Acceder al servidor en: http://$(terraform output -raw public_ip_address)"
echo ""
echo "Recuerda destruir los recursos con './destroy.sh' cuando ya no los necesites."
echo "Esto evitará costos innecesarios."