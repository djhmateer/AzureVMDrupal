#!/bin/bash

# activate debugging from here
set -x

# to ease spinning up and down environments, increment this number each time
int=6

rg=DaveDrupalTESTx${int}
dnsname=davedrupaltestx${int}
adminusername=azureuserx${int}
adminpassword=zp1234567890TESTx${int}

vmname=davedrupaltest

region=westeurope
vnet=vnet
subnet=subnet
publicIPName=publicIP
nsgname=nsg
nicName=nic
image=UbuntuLTS
###
# Create VNET #
###
echo "-= Creating Resource Group ${rg} "
az group create \
   --name ${rg} \
   --location ${region}

az network vnet create \
    --resource-group ${rg} \
    --name ${vnet} \
    --address-prefix 192.168.0.0/16 \
    --subnet-name ${subnet} \
    --subnet-prefix 192.168.1.0/24

# note the static IP address here
az network public-ip create \
    --resource-group ${rg} \
    --name ${publicIPName} \
    --allocation-method Static \
    --dns-name ${dnsname}

az network nsg create \
    --resource-group ${rg} \
    --name ${nsgname}

# allow ssh
az network nsg rule create \
    --resource-group ${rg} \
    --nsg-name ${nsgname} \
    --name nsgGroupRuleSSH \
    --protocol tcp \
    --priority 1000 \
    --destination-port-range 22 \
    --access allow

# allow port 80
az network nsg rule create \
    --resource-group ${rg} \
    --nsg-name ${nsgname} \
    --name nsgGroupRuleWeb80 \
    --protocol tcp \
    --priority 1001 \
    --destination-port-range 80 \
    --access allow

# allow port 443
az network nsg rule create \
    --resource-group ${rg} \
    --nsg-name ${nsgname} \
    --name nsgGroupRuleWeb443 \
    --protocol tcp \
    --priority 1002 \
    --destination-port-range 443 \
    --access allow

#create a virtual nic
az network nic create \
    --resource-group ${rg} \
    --name ${nicName} \
    --vnet-name ${vnet} \
    --subnet ${subnet} \
    --public-ip-address ${publicIPName} \
    --network-security-group ${nsgname}

#create vm which runs the cloud init script to provision apache, php etc
az vm create \
    --resource-group ${rg} \
    --name ${vmname} \
    --location ${region} \
    --nics ${nicName} \
    --image ${image} \
    --admin-username ${adminusername} \
    --admin-password ${adminpassword} \
    --custom-data cloud-init.txt 

echo -e "\nssh ${adminusername}@${dnsname}.westeurope.cloudapp.azure.com\n${adminpassword}"
