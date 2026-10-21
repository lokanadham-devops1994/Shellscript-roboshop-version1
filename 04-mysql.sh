#!/bin/bash
user_id=$(id -u)
logs_folder="/var/log/roboshop"
log_file="${logs_folder}/${0}.log"
R="\e[1;31m"
G="\e[1;32m"
Y="\e[1;33m"
M="\e[1;35m"
N="\e[0m"
if [ $user_id -ne 0 ]; then
  echo "Please run this script with root privileges."
    exit 0
else
    echo "You are running this script as root user with sudo acess,you can be accessed successfully."
fi 
mkdir -p "$logs_folder"
echo "Script execution started at $(date +"%F %T")" &>> $log_file
timestamp(){
    date +"%F %T"
}
validate(){
    if [ $1 -ne 0 ]; then
        echo -e "${Y}$(timestamp) [ERROR]${N} ${2} ${R}Failed!${N}" | tee -a $log_file
        exit 1
    else    
        echo -e "${Y}$(timestamp) [INFO]${N} ${2}  ${G}Successful!${N}" | tee -a $log_file
        fi
}
echo "$(timestamp) [INFO]===Script excution started====" | tee -a $log_file
dnf module enable mysql:8.4 -y &>> $log_file
dnf install mysql-server -y &>> $log_file
validat $? "Installing MYSQL Sever"
systemctl enable mysqld &>> $log_file
systemctl start mysqld &>> $log_file
validat $? "Start & Enable MYSQL server"
mysql_secure_installation --set-root-pass Roboshop@1 &>> $log_file
validate $? "Setup MYSQL root password"
echo "$(timestamp) [INFO] Script excution to take time "$SECONDS" in seconds" | tee -a $log_file
echo "$(timestamp) [INFO]===Script excution completed====" | tee -a $log_file