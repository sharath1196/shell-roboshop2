#!/bin/bash
app_name="frontend"
source ./common.sh

# check the user has root priveleges or not
check_root

# validate functions takes input as exit status, what command they tried to install

dnf module disable nginx -y &>> $LOG_FILE
VALIDATE $? "Disabling default nginx"

dnf module enable nginx:1.24 -y &>> $LOG_FILE
VALIDATE $? "enabling required nginx"

dnf install nginx -y &>> $LOG_FILE
VALIDATE $? "Installing nginx"

systemctl enable nginx &>> $LOG_FILE
systemctl start nginx &>> $LOG_FILE
VALIDATE $? "Successfully Starting nginx"

artifact_setup

rm -rf /etc/nginx/nginx.conf
VALIDATE $? "Removing the basic configuration file"

cp $SCRIPT_DIR/nginx.conf /etc/nginx/nginx.conf
VALIDATE $? "Adding a new config file"

systemctl restart nginx &>> $LOG_FILE
VALIDATE $? "Successfully restarting nginx"
