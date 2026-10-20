#!/bin/bash
user_id=$(id -u)
logs_folder="/var/log/shellscript-Practice"
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
        echo -e "${Y}$(timestamp) [INFO]${N} ${2} ${G}Successful!${N}" | tee -a $log_file
        fi
}
echo "$(timestamp) [INFO]===Script excution started====" | tee -a $log_file
cp mongo.repo /etc/yum.repos.d/mongo.repo
validate $? "Adding mongo.repo"
dnf install mongodb-org -y &>> $log_file
validate $? "Install MongoDB"
systemctl enable mongod &>> $log_file
systemctl start mongod &>> $log_file
validate $? "Start & enable the MongoDB service"
sed -i 's/127.0.0.1/0.0.0.0/' /etc/mongod.conf &>> $log_file
validate $? "Update remote connection to MongoDB"
systemctl restart mongod &>> $log_file
validate $? "Restat MongoDB"
echo "$(timestamp) [INFO]===Script excution completed====" | tee -a $log_file
echo "Script execution completed at $(date +"%F %T")" &>> $log_file