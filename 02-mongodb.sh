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
validate(){
    if [ $1 -ne 0 ]; then
        echo -e "${2} ${R}Failed!${N}" | tee -a $log_file
        exit 1
    else    
        echo -e "${2}  ${G}Successful!${N}" | tee -a $log_file
        fi
cp mongo.repo /etc/yum.repos.d/mongo.repo
validate $? "Adding mongo.repo"
dnf install mongodb-org -y &>> $log_file
validate $? "Install MongoDB"
systemctl enable mongod &>> $log_file
systemctl start mongod &>> $log_file
validate $? "Start & enable the MongoDB service:"



















}
for package in $@;
    do
        dnf list installed $package &>> $log_file
        if [ $? -ne 0 ]; then
            echo -e "${M}Going to install:${package},${G}SUCCESSFULLY!${N}"
            dnf install $package -y &>> $log_file
            validate $? "installaling ${package}"
        else
        echo -e "${M}Already installed:${package},${Y}SKIPPING!{N}"
        fi
    done
echo "Script execution completed at $(date +"%F %T")" &>> $log_file