#!/bin/bash

# activate debugging from here
set -x

rg=DaveMysqlTEST1
region=westeurope

# db name must be unique 
mysqlserver=davetestx
sqladmin=adminusernamex
sqlpassword=password123456789

echo "create resource group ${rg}"
az group create \
   --name ${rg} \
   --location ${region}

# careful of GP_Gen5_2
echo "create mysql server"
az mysql server create \
    --resource-group ${rg} \
    --name ${mysqlserver} \
    --location ${region} \
    --admin-user ${sqladmin} \
    --admin-password ${sqlpassword} \
    --sku-name GP_Gen5_2 \
    --ssl-enforcement Disabled \
    --version 5.7
    --storage-size 50000


#configure firewalls
echo "begin azure firewall"
az mysql server firewall-rule create \
    --name allAzureIPs \
    --server ${mysqlserver} \
    --resource-group ${rg} \
    --start-ip-address 0.0.0.0 \
    --end-ip-address 0.0.0.0

echo "end azure firewall"