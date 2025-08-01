






#!/bin/bash

USERID=$(id -u)
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"
LOGS_FOLDER="/var/log/roboshop-logs"
SCRIPT_NAME=$(echo $0 | cut -d "." -f1)
LOG_FILE="$LOGS_FOLDER/$SCRIPT_NAME.log"
SCRIPT_DIR=$PWD
START_TIME=$(date +%s)

mkdir -p $LOGS_FOLDER
echo "Script started executing at: $(date)" | tee -a $LOG_FILE

# check the user has root priveleges or not
if [ $USERID -ne 0 ]
then
    echo -e "$R ERROR:: Please run this script with root access $N" | tee -a $LOG_FILE
    exit 1 #give other than 0 upto 127
else
    echo "You are running with root access" | tee -a $LOG_FILE
fi

# validate functions takes input as exit status, what command they tried to install
VALIDATE(){
    if [ $1 -eq 0 ]
    then
        echo -e "$2 is ... $G SUCCESS $N" | tee -a $LOG_FILE
    else
        echo -e "$2 is ... $R FAILURE $N" | tee -a $LOG_FILE
        exit 1
    fi
}



dnf install python3 gcc python3-devel -y &>> $LOG_FILE
VALIDATE $? "Installing python"

id roboshop
if [ $? -ne 0 ]
then
    useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop
    VALIDATE $? "Adding a user 'roboshop'"
else
    echo "User already created"
fi

mkdir -p /app 
VALIDATE $? "Making a working directory for roboshop user" 

curl -L -o /tmp/payment.zip https://roboshop-artifacts.s3.amazonaws.com/payment-v3.zip 
VALIDATE $? "Downloading the artifact"

cd /app 
rm -rf /app/*
unzip /tmp/payment.zip &>> $LOG_FILE
VALIDATE $? "Extracting the artifact"

cd /app 
pip3 install -r requirements.txt &>> $LOG_FILE
VALIDATE $? "Installing the artifact"

cp $SCRIPT_DIR/payment.service /etc/systemd/system/payment.service
VALIDATE $? "Copying the service "

systemctl daemon-reload &>> $LOG_FILE
systemctl enable payment  &>> $LOG_FILE
systemctl start payment &>> $LOG_FILE
VALIDATE $? "Starting Payment service "