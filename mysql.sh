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

dnf install mysql-server -y &>> $LOG_FILE
VALIDATE $? "Installing MySql"

systemctl enable mysqld
systemctl start mysqld   &>> $LOG_FILE
VALIDATE $? "Starting MySql"


read -sp "Enter your Password : " PASSWORD
echo
mysql_secure_installation --set-root-pass "$PASSWORD"
VALIDATE $? "Setting up Password"



END_TIME=$(date +%s)
TOTAL_TIME=$(( $END_TIME - $START_TIME ))
echo "Total time taken to execute the script : $TOTAL_TIME seconds" | tee -a $LOG_FILE
