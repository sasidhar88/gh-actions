#!/bin/bash
echo "Printing teh secrets to the screen"
# echo $MONGO | sed 's/./& /g'
# echo ${{ secrets[format('MONGO_PASS_{0}', inputs.cluster)] }} | sed 's/./& /g'
# echo ${{ secrets[format('MONGO_PASS_{0}', inputs.cluster)] }} | sed 's/./& /g'
# echo ${{ secrets[format('MONGO_PASS_{0}', inputs.cluster)] }} | sed 's/./& /g'
# echo ${{ secrets[format('MONGO_PASS_{0}', inputs.cluster)] }} | sed 's/./& /g'
array=('MONGO_USER' 'MONGO_PASSWORD' 'MONGO_CONNECTION_STRING' 'CIDRBLOCK' 'PRIVATE_KEY' 'PUBLIC_KEY' 'GROUP_ID')

# Accessing the environment variables set in the workflow
echo "Mongo User: $MONGO_USER"
echo "Mongo Password: $MONGO_PASSWORD"
echo "Mongo Connection String: $MONGO_CONNECTION_STRING"
echo "CIDR Block: $CIDRBLOCK"
echo "Private Key: $PRIVATE_KEY"
echo "Public Key: $PUBLIC_KEY"
echo "Group ID: $GROUP_ID"


#Defining a function to setup values.
setValues () {
    
    #: Defining MongoDB Staging cluster creds.
    declare -g USERNAME=$MONGO_USER
    declare -g PASSWORD=$MONGO_PASSWORD
    #: Defing public key, private key and group id for the staging mongodb cluster
    declare -g publickey=$PRIVATE_KEY
    declare -g privatekey=$PUBLIC_KEY
    #: Defining the cidr range for the staging vpc and nat gateway 
    declare -g cidrblock=$CIDRBLOCK
    declare -g natgw=$NATGW
    declare -g groupid=$GROUP_ID
    #: Defing source mongodb connection string
    #declare -g source_prod_url=$MONGO_CONNECTION_STRING_PROD_EU
    #declare -g mongodb_prod_user=$MONGO_USER_PROD_EU
    #declare -g mongodb_prod_pass=$MONGO_PASS_PROD_EU
}
setValues

#: Proceesing the cidr block and natgw id
processingCidrBlock () {
    #: processing the cidr block and natgw.
    declare -g cidrblock=$(echo "${!cidrblock}" | sed 's/%2F/\//g')
    declare -g natgw=$(echo "${!natgw}" | sed 's/%2F/\//g')
}

processingCidrBlock

echo "Pronting teh cidrblock and natgw"
echo "$cidrblock"
echo "$natgw"
