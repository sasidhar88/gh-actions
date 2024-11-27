#!/bin/bash
#: Title: Mongo Backup and Restore Scripts

#: Defining an array to store the MongoDB connection strings based on environment.
declare -A mongoENVConnectionStringsMap
mongoENVConnectionStringsMap () {
    #: Defining the environments to Restore.
    mongoENVConnectionStringsMap["staging"]=""
    mongoENVConnectionStringsMap["uat"]=""
    mongoENVConnectionStringsMap["dev"]=""
    mongoENVConnectionStringsMap["uat-eu"]="Mongo-EU-Cluster"
}

#: Defining a function to validate provided environment exists.
envValidation () {
    #: Validating the provided environment.
    if [[ -n ${mongoENVConnectionStringsMap[$env]} ]]
    then
        echo "The provided enviroment exists."
        echo "The connections string which will be used to restore is ${mongoENVConnectionStringsMap["$env"]}"
    else
        echo "The provided environment doesn't exists.Hence exiting the script."
        exit 1
    fi

}


#Defining a function to setup values.
setValues () {
    
    #: Defining MongoDB Staging cluster creds.
    declare -g USERNAME=$(eval echo "mongodb_user_\$env")
    declare -g PASSWORD=$(eval echo "mongodb_pass_\$env")
    #: Defing public key, private key and group id for the staging mongodb cluster
    declare -g publickey=$(eval echo "mongodb_api_pub_\$env")
    declare -g privatekey=$(eval echo "mongodb_api_pvt_\$env")
    #: Defining the cidr range for the staging vpc and nat gateway 
    declare -g cidrblock=$(eval echo "cidrblock_\$env")
    declare -g natgw=$(eval echo "natgw_\$env")
    declare -g groupid=$(eval echo "groupid_\$env")

}


#: Defining an array for the collections to be skipped.
IFS=', ' read -ra collectionsToExclude <<< "${collectionsToExclude}"


#: Declaring an array for Black Listed COllections
declare -a BlackListedCollections
#: Collection array function
collectionArray () {
    #: formating the collections to be skipped.
    for collection in "${collectionsToExclude[@]}"
    do
    collectionName=" --excludeCollection=${collection}"
    BlackListedCollections+=("${collectionName}")
    done
}


#: Defining the list of dbs to be backed up and restored.
IFS=', ' read -ra dbNames <<< "${dbNames}"



#: Defining a function to print parameters to the screen
printParams () {

    #: Printing the parameters to the console.
    echo "##################################################################################################"
    echo "##############################Parameters Recieved for this job####################################"
    echo "##################################################################################################"
    echo "The selected MongoDb cluster to restore is ${env}"
    echo "The list of dbs which will be dumped and restored to selected environment of mongodb cluster."
    printf "%s\n" ${dbNames[@]}
    echo "##################################################################################################"
    echo "The following collections to be skipped."
    echo "##################################################################################################"
    printf "%s\n"  ${BlackListedCollections[@]}
    echo ""
    echo ${mongoENVConnectionStringsMap["$env"]}
    echo ""

}



#: Defining a status check function.
status(){
  if [[ $? != 0 ]]
  then
    faileddbs+=("$dbName")
    echo "Error: ${1}"
  else
     echo "Restored DB: ${dbName} successfully to ${env} MongoDB Cluster."
  fi
}


#: slack message


#: Defing a function to list the white listed ips from selcted mongodb cluster.
accessList () {
    #: command to list the white listed ip's from the 
    echo "The following are the white listed ip's from the $env mongodb cluster."
    curl -s --user "${!publickey}:${!privatekey}" --digest \
        --header "Accept: application/vnd.atlas.2023-11-15+json" \
        -X GET "https://cloud.mongodb.com/api/atlas/v2/groups/${!groupid}/accessList?pretty=true" | jq -r '.results[] | {cidrBlock: .cidrBlock, comment: .comment}'
    echo  ""

}

#: Defining a function to delete the provided ip's from $env MongoDB cluster.
deleteEntry (){
      for item in $@
      do
            echo "Deleting the following cidr range ${item} from the mongodb cluster"
            curl -s --user "${!publickey}:${!privatekey}" --digest \
                  --header "Accept: application/vnd.atlas.2023-11-15+json" \
                   -X DELETE "https://cloud.mongodb.com/api/atlas/v2/groups/${!groupid}/accessList/${item}"
      done
      echo  ""
}

#: Proceesing the cidr block and natgw id
processingCidrBlock () {
    #: processing the cidr block and natgw.
    declare -g cidrblock=$(echo "${!cidrblock}" | sed 's/%2F/\//g')
    declare -g natgw=$(echo "${!natgw}" | sed 's/%2F/\//g')
}

#: Defining an empty array of successfull db dump and restore
declare -a faileddbs

#: Defining the function for mongodump and restore
mongoDumpRestore () {
      
        #: Looping through the dbs to be dumped and restored.
        for dbName in ${dbNames[@]}
        do
            echo "Taking the dump for the DB: ${dbName}"
            mongodump --host ${source_prod_url} --ssl --username ${mongodb_prod_user} --password ${mongodb_prod_pass} --authenticationDatabase admin  --db ${dbName} ${BlackListedCollections[@]} ${dbSpecificCollectionsToskip[$dbName]} --archive | mongorestore --host ${mongoENVConnectionStringsMap["$env"]} --ssl --username ${!USERNAME} --password ${!PASSWORD} --authenticationDatabase admin --db ${dbName}  --noIndexRestore --numInsertionWorkersPerCollection=2 --drop --archive
            status "Something went wrong while backup and restore activity on the following DB: ${dbName}, Please check the logs for more informantion..."
        done
        
}

#: Defining a function to store list of failed dbs to an array defined above
failedDbs () { 
    if [[ -n "${faileddbs[@]}" ]]
    then
        echo "##################################################################################################"
        echo "The following dbs have been failed to restore.Please check and try again by selecting these dbs."
        printf "%s\n"  ${faileddbs[@]}
        echo "##################################################################################################"
    fi
}

#: Defining the function to  whitelist VPC CIDR and NATGW on MongoDB cluster
whitelistCidrBlock () {

    #: Adding the entry back to $env MongoDB Cluster.
    curl -s --user "${!publickey}:${!privatekey}" \
        --digest \
        --header "Accept: application/vnd.atlas.2023-11-15+json" \
        --header "Content-Type: application/json" \
        -X POST \
        "https://cloud.mongodb.com/api/atlas/v2/groups/${!groupid}/accessList" \
        --data '[ { "cidrBlock": "'"${cidrblock}"'", "comment": "'"${env}"' VPC CIDR" }, { "cidrBlock": "'"${natgw}"'", "comment": "'"${env}"' natgw" } ]'
    echo ""
}
