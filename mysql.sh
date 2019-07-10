#!/bin/bash

# activate debugging from here
set -x

int=3
rg=DaveMysqlTEST${int}
mysqlserver=davetestx${int}
dbname=davetest
sqladmin=adminusernamex${int}
sqlpassword=password123456789TKT${int}

region=westeurope
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
# Azure services
az mysql server firewall-rule create \
    --name allAzureIPs \
    --server ${mysqlserver} \
    --resource-group ${rg} \
    --start-ip-address 0.0.0.0 \
    --end-ip-address 0.0.0.0

myip="$(dig +short myip.opendns.com @resolver1.opendns.com)"
echo "My WAN/Public IP address: ${myip}"

# allow current IP access to the db
az mysql server firewall-rule create \
    --name localIPToCreateDbCanRemove \
    --server ${mysqlserver} \
    --resource-group ${rg} \
    --start-ip-address ${myip} \
    --end-ip-address ${myip} 
echo "end azure firewall"

mysql -h ${mysqlserver}.mysql.database.azure.com -u ${sqladmin}@${mysqlserver} -p${sqlpassword} -e "create database ${dbname}"

# db connection helpers
echo -e "${dbname}\n${sqladmin}@${mysqlserver}\n${sqlpassword}\n${mysqlserver}.mysql.database.azure.com"
