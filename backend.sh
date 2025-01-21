#!/bin/bash

USERID=$(id -u)
R="\e[31m"
G="\e[32m"
Y="\e[33m"
LOGS_FOLDER="/var/log/expense-logs"
LOG_FILE=$(basename "$0" | cut -d "." -f1)
TIMESTAMP=$(date +%Y-%m-%d-%H-%M-%S)
LOG_FILE_NAME="$LOGS_FOLDER/$LOG_FILE-$TIMESTAMP.log"

VALIDATE() {
    if [ $1 -ne 0 ]; then
        echo -e "$2......$R failure \e[0m"
        exit 1
    else
        echo -e "$2.......$G success \e[0m"
    fi
}

CHECK_ROOT() {
    if [ $USERID -ne 0 ]; then  
        echo -e "${R}Error: User does not have root access. Please run as root or use sudo.${Y}"
        exit 1
    fi
}

echo "Script started and executed at: $TIMESTAMP"

# Ensure log directory exists
mkdir -p "$LOGS_FOLDER"

CHECK_ROOT

dnf module disable nodejs -y &>>"$LOG_FILE_NAME"
VALIDATE $? "disableing existing nodejs"

dnf module enable nodejs:20 -y &>>"$LOG_FILE_NAME"
VALIDATE $? "enabeling nodejs 20 version"

dnf install nodejs -y &>>"$LOG_FILE_NAME"
VALIDATE $? "Installing nodejs"

id expense &>>"$LOG_FILE_NAME"
if [ $? -ne 0 ]
then
    useradd expense &>>"$LOG_FILE_NAME"
    VALIDATE $? "adding expense user"
else
    echo -e "expense user is already exist .....skipping"
fi    

mkdir -p /app &>>"$LOG_FILE_NAME"
VALIDATE $? "making app directory"

curl -o /tmp/backend.zip https://expense-builds.s3.us-east-1.amazonaws.com/expense-backend-v2.zip &>>"$LOG_FILE_NAME"
VALIDATE $? "dowloading backend application"

cd /app
rm -rf /app/*

unzip /tmp/backend.zip &>>"$LOG_FILE_NAME"
VALIDATE $? "unziping backend apllication"

cd /app

npm install &>>"$LOG_FILE_NAME"
VALIDATE $? "installing npm"

cp /ec2-user/backend.service /etc/systemd/system/backend.service

dnf install mysql -y &>>"$LOG_FILE_NAME"
VALIDATE $? "installing mysql client"

mysql -h mysql.hariexpensive.store -u root -pExpenseApp@1 < /app/schema/backend.sql &>>"$LOG_FILE_NAME"
VALIDATE $? "setuping the transcations schema"

systemctl daemon-reload &>>"$LOG_FILE_NAME"
VALIDATE $? "rloading the daemon"

systemctl enable backend &>>"$LOG_FILE_NAME"
VALIDATE $? "enabeling backend"

systemctl restart backend &>>"$LOG_FILE_NAME"
VALIDATE $? "restarting the backend"

