#!/bin/bash

source ./common.sh

# check the user has root priveleges or not
check_root

dnf module disable redis -y &>> $LOG_FILE
VALIDATE $? "Disabling default redis"

dnf module enable redis:7 -y &>> $LOG_FILE
VALIDATE $? "Enabling required redis"

dnf install redis -y &>> $LOG_FILE
VALIDATE $? "Installing required redis"

sed -i 's/bind 127.0.0.1/bind 0.0.0.0/' /etc/redis/redis.conf
VALIDATE $? "Changing bind address to 0.0.0.0"

sed -i 's/protected-mode yes/protected-mode no/' /etc/redis/redis.conf
VALIDATE $? "Turning off Protected mode"

systemctl enable redis 
systemctl start redis 
VALIDATE $? "Starting redis"