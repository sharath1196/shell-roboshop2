#!/bin/bash
app_name="dispatch"
source ./common.sh

# check the user has root priveleges or not
check_root

create_user

artifact_setup

dnf install golang -y &>> $LOG_FILE
VALIDATE $? "Installing golang"

cd /app 
go mod init dispatch &>> $LOG_FILE
go get &>> $LOG_FILE
go build &>> $LOG_FILE
VALIDATE $? "Building from the artifact"

cp dispatch.service /etc/systemd/system/dispatch.service
VALIDATE $? "Copying the service "

systemctl daemon-reload &>> $LOG_FILE
systemctl enable dispatch  &>> $LOG_FILE
systemctl start dispatch &>> $LOG_FILE
VALIDATE $? "Starting dispatch service "