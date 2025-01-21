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

dnf install nginx -y  &>>"$LOG_FILE_NAME"
VALIDATE $? "Installing nginx"

systemctl enable nginx &>>"$LOG_FILE_NAME"
VALIDATE $? "enableing nginx"

systemctl start nginx &>>"$LOG_FILE_NAME"
VALIDATE $? "starting nginx"

rm -rf /usr/share/nginx/html/* &>>"$LOG_FILE_NAME"
VALIDATE $? "removing existing vesrion of control"

curl -o /tmp/frontend.zip https://expense-builds.s3.us-east-1.amazonaws.com/expense-frontend-v2.zip &>>"$LOG_FILE_NAME"
VALIDATE $? "downloading new code"

cd /usr/share/nginx/html &>>"$LOG_FILE_NAME"
VALIDATE $? "moving to html directory"

unzip /tmp/frontend.zip &>>"$LOG_FILE_NAME"
VALIDATE $? "unzipiing the frontend"

cp /home/ec2-user/expense-shell-project/expense.conf /etc/nginx/default.d/expense.conf

systemctl restart nginx &>>"$LOG_FILE_NAME"
VALIDATE $? "restarting nginx"