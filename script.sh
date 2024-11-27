#!/bin/bash
echo "Printing teh secrets to the screen"
# echo $MONGO | sed 's/./& /g'
# echo ${{ secrets[format('MONGO_PASS_{0}', inputs.cluster)] }} | sed 's/./& /g'
# echo ${{ secrets[format('MONGO_PASS_{0}', inputs.cluster)] }} | sed 's/./& /g'
# echo ${{ secrets[format('MONGO_PASS_{0}', inputs.cluster)] }} | sed 's/./& /g'
# echo ${{ secrets[format('MONGO_PASS_{0}', inputs.cluster)] }} | sed 's/./& /g'
array=('MONGO_USER' 'MONGO_PASSWORD' 'MONGO_CONNECTION_STRING' 'CIDRBLOCK' 'PRIVATE_KEY' 'PUBLIC_KEY' 'GROUP_ID')

for item in ${array[@]}
do
  echo "Printing the value for the variable: $item"
  echo $item | sed 's/./& /g'
done
