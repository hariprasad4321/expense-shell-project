#!/bin/bash
USERID=$(id -u)
R="\e[31m"
G="\e[32m"
Y="\e[33m"
LOGS_FOLDER="/var/log/expense-logs"
LOG_FILE=$(echo $0 | cut -d "." -f1)
TIMESTAMP=$(date +%Y-%m-%d-%H-%M-%S)
LOG_FILE_NAME="$LOGS_FOLDER/$LOG_FILE/-$TIMESTAMP.log"

VALIDATE(){
if [ $1 -ne 0 ]
then
    echo -e "$2......$R failure"
    exit 1
else
    echo -e "$2.......$G success"
fi
}

CHECK_ROOT(){

if [ $USERID -ne 0 ]
then  
    echo "Error:throw the error message user does not have root access"
    exit 1
fi
}
echo "script started at and excuted at: $TIMESTAMP"

CHECK_ROOT

dnf install mysql-server -y &>>$LOG_FILE_NAME
VALIDATE $? "Installing Mysql-sever"

systemctl enable mysqld &>>$LOG_FILE_NAME
VALIDATE $? "Enableing Mysql-sever"

systemctl start mysqld &>>$LOG_FILE_NAME
VALIDATE $? "Starting Mysql-server"

mysql_secure_installation --set-root-pass ExpenseApp@1
VALIDATE $? "Setting up root password"


