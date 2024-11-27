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
