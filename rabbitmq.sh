#!/bin/bash

source ./common.sh

# check the user has root priveleges or not
check_root

# validate functions takes input as exit status, what command they tried to install
VALIDATE(){


cp rabbitmq.repo /etc/yum.repos.d/rabbitmq.repo
VALIDATE $? "Copying RabbitMQ repo"

dnf install rabbitmq-server -y &>> $LOG_FILE
VALIDATE $? "Installing RabbitMQ"

systemctl enable rabbitmq-server
systemctl start rabbitmq-server
VALIDATE $? "Starting RabbitMQ"

# RabbitMQ comes with a default username / password as guest/guest. 
# But this user cannot be used to connect. Hence, we need to create one user for the application.

read -p "Enter user name : " USERNAME
read -sp "Enter your Password : " PASSWORD
echo

rabbitmqctl add_user $USERNAME $PASSWORD
VALIDATE $? "Creating RabbitMQ User"

rabbitmqctl set_permissions -p / $USERNAME ".*" ".*" ".*"
VALIDATE $? "Setting Permissions for RabbitMQ User"

END_TIME=$(date +%s)
TOTAL_TIME=$(( $END_TIME - $START_TIME ))
echo "Total time taken to execute the script : $TOTAL_TIME seconds" | tee -a $LOG_FILE