#!/bin/bash
app_name="user"

source ./common.sh

# check the user has root priveleges or not
check_root

create_user

artifact_setup

node_setup

cp $SCRIPT_DIR/user.service /etc/systemd/system/user.service
VALIDATE $? "Copying the service file"

systemctl daemon-reload &>> $LOG_FILE
systemctl enable user &>> $LOG_FILE
systemctl start user &>> $LOG_FILE

VALIDATE $? "User service"

END_TIME=$(date +%s)
TOTAL_TIME=$(( $END_TIME - $START_TIME ))
echo "Total time taken to execute the script : $TOTAL_TIME seconds" | tee -a $LOG_FILE
