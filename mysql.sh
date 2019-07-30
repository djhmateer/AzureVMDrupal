#!/bin/bash

# activate debugging from here
set -x

# generate random suffix
int=$(shuf -i 1-1000 -n 1)
# 14 character password
password=!!ZZ6329$(head /dev/urandom | tr -dc A-Za-z0-9 | head -c6)

rg=DaveMysqlTEST${int}
mysqlserver=davetest${int}
dbname=davetest
sqladmin=adminuser${int}
sqlpassword=${password}


region=westeurope
echo "create resource group ${rg}"
az group create \
   --name ${rg} \
   --location ${region}

# careful: cheap is B_Gen5_1, prod is GP_Gen5_2
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
# save to file
echo -e "${dbname}\n${sqladmin}@${mysqlserver}\n${sqlpassword}\n${mysqlserver}.mysql.database.azure.com" & > db.txt
