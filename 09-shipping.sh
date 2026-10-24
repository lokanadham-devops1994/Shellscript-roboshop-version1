#!/bin/bash
user_id=$(id -u)
logs_folder="/var/log/roboshop"
log_file="${logs_folder}/${0}.log"
domain_name="daws-92s.shop"
script_dir=$(dirname "$(realpath "$0")")
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
echo -e "${M}Script execution started at $(date +"%F %T")${N}" &>> $log_file
timestamp(){
    date +"%F %T"
}
validate(){
    if [ $1 -ne 0 ]; then
        echo -e "${Y}$(timestamp) [ERROR]${N} ${2} ${R}Failed!${N}" | tee -a $log_file
        exit 0
    else    
        echo -e "${Y}$(timestamp) [INFO]${N} ${2}  ${G}Successful!${N}" | tee -a $log_file
    fi
}
echo -e "${M}$(timestamp) [INFO]===Script excution started====${N}" | tee -a $log_file
dnf module enable maven:3.9 -y &>> $log_file
dnf install maven java-25-openjdk-devel -y &>> $log_file
validate $? "Installing Maven & Java"
echo -e "${M}$(timestamp) [INFO] Script excution to take time "$SECONDS" in seconds${N}" | tee -a $log_file
echo -e "${M}$(timestamp) [INFO] ==== Script completed Execution =====${N}" | tee -a $logs_file

