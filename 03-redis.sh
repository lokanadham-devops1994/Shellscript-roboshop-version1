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
        echo -e "${Y}$(timestamp) [INFO]${N} ${2}  ${G}Successful!${N}" | tee -a $log_file
        fi
}
echo "$(timestamp) [INFO]===Script excution started====" | tee -a $log_file
dnf module disable redis -y &>> $log_file
dnf module enable redis:7 -y &>> $log_file
dnf install redis -y &>> $log_file
validate $? "Installing Redis" 
sed -i -e 's/^bind 127.0.0.1/bind 0.0.0.0/' -e 's/^protected-mode yes/protected-mode no/' /etc/redis/redis.conf &>> $log_file
validate $? "Update remote connection to Redis and also change protectedmode in redis.conf file"
systemctl enable redis &>> $log_file
validate $? "Enable Redis Server"
systemctl start redis &>> $log_file
validate $? "Stat Redis Server"
echo "${timestamp} [INFO]===Script excution completed====" | tee -a $log_file