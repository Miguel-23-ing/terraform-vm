#!/bin/bash

echo "Iniciando despliegue de infraestructura en Azure con Terraform"

if ! command -v terraform &> /dev/null; then
    echo "Terraform no está instalado. Instálalo primero."
    exit 1
fi

if ! command -v az &> /dev/null; then
    echo "Azure CLI no está instalado. Instálalo primero."
    exit 1
fi

if ! az account show &> /dev/null; then
    echo "No estás logueado en Azure. Ejecuta 'az login' primero."
    exit 1
fi


echo "Inicializando Terraform."
terraform init

if [ $? -ne 0 ]; then
    echo "Error al inicializar Terraform"
    exit 1
fi

echo "Creando plan de despliegue de Terraform"
terraform plan -out=tfplan

if [ $? -ne 0 ]; then
    echo "Error al crear el plan de despliegue de Terraform"
    exit 1
fi

echo "Aplicando configuración de Terraform"
terraform apply tfplan

if [ $? -ne 0 ]; then
    echo "Error al aplicar la configuración de Terraform"
    exit 1
fi

echo ""
echo "Despliegue completado exitosamente!"
echo ""
echo "Detalles de la VM:"
echo "-------------------"
terraform output -json | jq -r '
"IP Pública: " + .public_ip_address.value,
"Usuario: " + .vm_admin_username.value,
"Comando SSH: " + .ssh_connection_command.value,
"Tamaño VM: " + .vm_size.value,
"Ubicación: " + .vm_location.value
'

echo ""
echo "Acceder al servidor en: http://$(terraform output -raw public_ip_address)"
echo ""
echo "Recuerda destruir los recursos con 'terraform destroy' cuando ya no los necesites."