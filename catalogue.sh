#!/bin/bash

source ./common.sh

# check the user has root priveleges or not
check_root

# validate functions takes input as exit status, what command they tried to install

dnf module disable nodejs -y &>> $LOG_FILE
VALIDATE $? "Disabling default nodejs"

dnf module enable nodejs:20 -y &>> $LOG_FILE
VALIDATE $? "enabling required nodejs"

dnf install nodejs -y &>> $LOG_FILE
VALIDATE $? "Installing nodejs"

id roboshop
if [ $? -ne 0 ]
then
    useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop
    VALIDATE $? "Adding a user 'roboshop'"
else
    echo "User already created"
fi

mkdir -p /app
VALIDATE $? "Making a home directory of roboshop user" 

curl -o /tmp/catalogue.zip https://roboshop-artifacts.s3.amazonaws.com/catalogue-v3.zip &>> $LOG_FILE
VALIDATE $? "Downloading the artifact"

cd /app 
rm -rf /app/*
unzip /tmp/catalogue.zip &>> $LOG_FILE
VALIDATE $? "Extracting the artifact files here"

cd /app 
npm install &>> $LOG_FILE
VALIDATE $? "Build the artifact" 

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

