#!/bin/bash

source ./common.sh
app_name="catalogue"
# check the user has root priveleges or not
check_root

# validate functions takes input as exit status, what command they tried to install

create_user

artifact_setup

node_setup 

cp $SCRIPT_DIR/catalogue.service /etc/systemd/system/catalogue.service
VALIDATE $? "Copying the service file"

systemctl daemon-reload &>> $LOG_FILE
systemctl enable catalogue &>> $LOG_FILE
systemctl start catalogue &>> $LOG_FILE

VALIDATE $? "Catalogue service"

cp $SCRIPT_DIR/mongodb.repo /etc/yum.repos.d/mongodb.repo
VALIDATE $? "Copying mongodb"

dnf install mongodb-mongosh -y &>> $LOG_FILE
VALIDATE $? "Installing mongodb client"

if [ $(mongosh --host mongod.daws84.fun --eval 'db.getMongo().getDBNames().indexOf("catalogue")') -lt 0 ]
then
    mongosh --host mongod.daws84.fun </app/db/master-data.js
    VALIDATE $? "Loading the data in the MongoDB"
else
    echo "DB already exits"
fi

