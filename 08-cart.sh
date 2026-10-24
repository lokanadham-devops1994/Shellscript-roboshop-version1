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
dnf module disable nodejs -y &>> $log_file
dnf module enable nodejs:24 -y &>> $log_file
dnf install nodejs -y &>> $log_file
validate $? "Installing nodjs 24"
id roboshop &>> $log_file
if [ $? -ne 0 ]; then
    useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop &>> $log_file
    validate $? "Creating roboshop system user for roboshop cart"
else
    echo -e "${Y}$(timestamp) [INFO]${N} roboshop sysem user is already exist....${Y}SKIPPING!${N}"
fi
rm -rf /app
validate $? "Removing old code in /app directory"
mkdir -p /app
validate $? "Create app directory in roboshop cart"
curl -L -o /tmp/cart.zip https://raw.githubusercontent.com/daws-92s/roboshop-documentation/refs/heads/main/artifacts/cart-v4.zip &>> $log_file
validate $? "Downloading roboshop cart zip file from web"
cd /app
unzip /tmp/cart.zip &>> $log_file
validate $? "Extracting cart unzip file"
npm install &>> $log_file
validate $? "Installing dependecies"
sed -i "s/DOMAIN_NAME/$domain_name/g" "$script_dir/cart.service"
validate $? "Replacing DOMAIN_NAME in cart service"
cp "$script_dir/cart.service" /etc/systemd/system/cart.service
validate $? "Copying cart.service to /etc/systemmd/system/"
systemctl daemon-reload &>> $log_file
validate $? "Daemon reload"
systemctl enable cart.service &>> "$log_file"
validate $? "Enabling cart.service"
systemctl start cart.service &>> "$log_file"
validate $? "Starting cart.service"
systemctl restart cart
validate $? "Restarting cart"
echo -e "${M}$(timestamp) [INFO] Script excution to take time "$SECONDS" in seconds${N}" | tee -a $log_file
echo -e "${M}$(timestamp) [INFO] ==== Script completed Execution =====${N}" | tee -a $logs_file