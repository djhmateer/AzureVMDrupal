#!/bin/bash

# activate debugging from here
set -x

rg=DaveMysqlTEST3
region=westeurope

# db name must be unique 
mysqlserver=davetestx
sqladmin=adminusernamex
sqlpassword=password123456789TKT

echo "create resource group ${rg}"
az group create \
   --name ${rg} \
   --location ${region}

# careful of cheap is B_Gen5_1, prod is GP_Gen5_2
echo "create mysql server"
az mysql server create \
    --resource-group ${rg} \
    --name ${mysqlserver} \
    --location ${region} \
    --sku-name GP_Gen5_2 \
    --admin-user ${sqladmin} \
    --admin-password ${sqlpassword} \
    --ssl-enforcement Disabled \
    --version 5.7
    --storage-size 50000

# --sku-name B_Gen5_1 \
# --sku-name GP_Gen5_2 \

#configure firewalls
echo "begin azure firewall"
az mysql server firewall-rule create \
    --name allAzureIPs \
    --server ${mysqlserver} \
    --resource-group ${rg} \
    --start-ip-address 0.0.0.0 \
    --end-ip-address 0.0.0.0

echo "end azure firewall"