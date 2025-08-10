#!/bin/bash
app_name="shipping"

source ./common.sh

# check the user has root priveleges or not
check_root

create_user

artifact_setup

dnf install maven -y &>> $LOG_FILE
VALIDATE $? "Disabling default nodejs"


cd /app 
mvn clean package &>> $LOG_FILE
VALIDATE $? "Building the artifact" 

mv target/shipping-1.0.jar shipping.jar
VALIDATE $? "Moving the jar file to /app/" 

cp $SCRIPT_DIR/shipping.service /etc/systemd/system/shipping.service
VALIDATE $? "Copying the service file"


systemctl daemon-reload &>> $LOG_FILE
systemctl enable shipping &>> $LOG_FILE
systemctl start shipping &>> $LOG_FILE
VALIDATE $? "shipping service"


dnf install mysql -y &>> $LOG_FILE
VALIDATE $? "Installing mysql client"

read -sp "Enter your Password : " PASSWORD
echo

mysql -h mysql.daws84.fun -u root -p$PASSWORD -e 'use cities' &>> $LOG_FILE
if [ $? -ne 0 ]
then
    mysql -h mysql.daws84.fun -uroot -p$PASSWORD < /app/db/schema.sql &>> $LOG_FILE
    mysql -h mysql.daws84.fun -uroot -p$PASSWORD < /app/db/app-user.sql &>> $LOG_FILE
    mysql -h mysql.daws84.fun -uroot -p$PASSWORD < /app/db/master-data.sql &>> $LOG_FILE
    VALIDATE $? "Loading the data into MySQL"
else
    echo -e "Data is already present in the MySQL ... $Y SKIPPING $N"
fi

systemctl restart shipping &>>$LOG_FILE
VALIDATE $? "Restart shipping"

print_time