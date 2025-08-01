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


check_root(){
    if [ $USERID -ne 0 ]
    then
        echo -e "$R ERROR:: Please run this script with root access $N" | tee -a $LOG_FILE
        exit 1 #give other than 0 upto 127
    else
        echo "You are running with root access" | tee -a $LOG_FILE
    fi
}


VALIDATE(){
    if [ $1 -eq 0 ]
    then
        echo -e "$2 is ... $G SUCCESS $N" | tee -a $LOG_FILE
    else
        echo -e "$2 is ... $R FAILURE $N" | tee -a $LOG_FILE
        exit 1
    fi
}

node_setup(){
    dnf module disable nodejs -y &>> $LOG_FILE
    VALIDATE $? "Disabling default nodejs"

    dnf module enable nodejs:20 -y &>> $LOG_FILE
    VALIDATE $? "enabling required nodejs"

    dnf install nodejs -y &>> $LOG_FILE
    VALIDATE $? "Installing nodejs"

    cd /app
    npm install &>> $LOG_FILE
    VALIDATE $? "Build the artifact" 
}

create_user(){
    id roboshop
    if [ $? -ne 0 ]
    then
        useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop
        VALIDATE $? "Adding a user 'roboshop'"
    else
        echo "User already created"
    fi
}

artifact_setup(){
    mkdir -p /app
    VALIDATE $? "Making a home directory of roboshop user" 

    curl -o /tmp/$app_name.zip https://roboshop-artifacts.s3.amazonaws.com/$app_name-v3.zip &>> $LOG_FILE
    VALIDATE $? "Downloading the artifact"

    cd /app 
    rm -rf /app/*
    unzip /tmp/$app_name.zip &>> $LOG_FILE
    VALIDATE $? "Extracting the artifact files here"
}

