#!/bin/bash
#: Title: ZPS_EU-Backup-Restore

#: importing functions from utis.sh file.
source ./utils.sh

#: Setting up the Mongodb Connection strings based on the env provided.
mongoENVConnectionStringsMap

#: Environment validation
envValidation

#: Setting up the values
setValues


#: Function to capture the list of collections to be skipped across the dbs.
collectionArray

#: Printing the params recieved for the JOb
printParams