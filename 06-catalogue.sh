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
echo "Script execution started at $(date +"%F %T")" &>> $log_file
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
echo "$(timestamp) [INFO]===Script excution started====" | tee -a $log_file
dnf module disable nodejs -y &>> $log_file
dnf module enable nodejs:24 -y &>> $log_file
dnf install nodejs -y &>> $log_file
validate $? "Installing nodjs 24"
id roboshop &>> $log_file
if [ $? -ne 0 ]; then
    useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop &>> $log_file
    validate $? "Creating roboshop system user for roboshop catalogue"
else
    echo -e "${Y}$(timestamp) [INFO]${N} roboshop sysem user is already exist....${Y}SKIPPING!${N}"
fi
rm -r /app
validate $? "Removing old code in /app directory"
mkdir -p /app
validate $? "Create app directory in roboshop catalogue"
curl -L -o /tmp/catalogue.zip https://raw.githubusercontent.com/daws-92s/roboshop-documentation/refs/heads/main/artifacts/catalogue-v4.zip &>> $log_file
validate $? "Downloading roboshop catalogue zip file from web"
cd /app
unzip /tmp/catalogue.zip &>> $log_file
validate $? "Extracting catalogue unzip file"
npm install &>> $log_file
validate $? "Installing dependecies"
sed -i "s/DOMAIN_NAME/$domain_name/g" "$script_dir/catalogue.service"
validate $? "Replacing DOMAIN_NAME in catalogue service"
cp "$script_dir/catalogue.service" /etc/systemd/system/catalogue.service
validate $? "Copying catalogue.service to /etc/systemmd/system/"
# Fix SEL inux context if SEL inux is enforcing (RHEL/CentOS/DNF Systems)
if command -v restorecon &> /dev/null; then
    restorecon -v /etc/systemd/system/catalogue.service
fi
systemctl daemon-reload &>> $log_file
validate $? "Daemon reload"
systemctl enable catalogue.service &>> "$log_file"
validate $? "Enabling catalogue.service"
systemctl start catalogue.service &>> "$log_file"
validate $? "Starting catalogue.service"
# 5. MongoDB repo and client installation
cp "$script_dir/mongo.repo" /etc/yum.repos.d/mongo.repo
validate $? "Creating mongo.repo"
dnf install -y mongodb-mongosh &>> "$log_file"
validate $? "Installing mongodb client server"



echo "$(timestamp) [INFO] Script excution to take time "$SECONDS" in seconds" | tee -a $log_file
echo "$(timestamp) [INFO]===Script excution completed====" | tee -a $log_file 