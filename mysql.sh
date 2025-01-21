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

dnf install mysql-server -y &>>"$LOG_FILE_NAME"
VALIDATE $? "Installing MySQL server"

systemctl enable mysqld &>>"$LOG_FILE_NAME"
VALIDATE $? "Enabling MySQL server"

systemctl start mysqld &>>"$LOG_FILE_NAME"
VALIDATE $? "Starting MySQL server"

mysql_secure_installation --set-root-pass ExpenseApp@1 &>>"$LOG_FILE_NAME"
VALIDATE $? "Setting up root password"
