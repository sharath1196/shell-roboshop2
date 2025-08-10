#!/bin/bash


source ./common.sh
app_name=cart

# check the user has root priveleges or not
check_root

artifact_setup

node_setup

create_user


cp $SCRIPT_DIR/cart.service /etc/systemd/system/cart.service
VALIDATE $? "Copying the service file"

systemctl daemon-reload &>> $LOG_FILE
systemctl enable cart &>> $LOG_FILE
systemctl start cart &>> $LOG_FILE

VALIDATE $? "cart service"

END_TIME=$(date +%s)
TOTAL_TIME=$(( $END_TIME - $START_TIME ))
echo "Total time taken to execute the script : $TOTAL_TIME seconds" | tee -a $LOG_FILE
