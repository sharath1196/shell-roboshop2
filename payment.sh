#!/bin/bash
app_name="payment"

source ./common.sh

# check the user has root priveleges or not
check_root

create_user

artifact_setup

dnf install python3 gcc python3-devel -y &>> $LOG_FILE
VALIDATE $? "Installing python"

cd /app 
pip3 install -r requirements.txt &>> $LOG_FILE
VALIDATE $? "Installing the artifact"

cp $SCRIPT_DIR/payment.service /etc/systemd/system/payment.service
VALIDATE $? "Copying the service "

systemctl daemon-reload &>> $LOG_FILE
systemctl enable payment  &>> $LOG_FILE
systemctl start payment &>> $LOG_FILE
VALIDATE $? "Starting Payment service "