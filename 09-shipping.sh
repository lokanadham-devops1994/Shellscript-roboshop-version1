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
alternatives --set java "/usr/lib/jvm/java-25-openjdk/bin/java"
validate S? "Setting Java 25 as default Java version"
echo "export JAVA_HOME=$(dirname $(dirname $(readlink -f /usr/bin/java)))" > /etc/profile.d/java.sh
source /etc/profile.d/java.sh
echo $JAVA_HOME
validate $? "Setting JAVA_HOME for Maven"
id roboshop &>> $log_file
if [ $? -ne 0 ]; then
    useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop &>> $log_file
    validate $? "Creating roboshop system user for roboshop shipping"
else
    echo -e "${Y}$(timestamp) [INFO]${N} roboshop sysem user is already exist....${Y}SKIPPING!${N}"
fi
rm -rf /app
validate $? "Removing old code in /app directory"
mkdir -p /app
validate $? "Create app directory in roboshop shipping"
curl -L -o /tmp/shipping.zip https://raw.githubusercontent.com/daws-92s/roboshop-documentation/refs/heads/main/artifacts/shipping-v4.zip &>> $log_file
validate $? "Downloading roboshop shipping zip file from web"
cd /app
unzip /tmp/shipping.zip &>> $log_file
validate $? "Extracting shipping unzip file"
mvn clean package &>> $log_file
validate $? "Installing dependecies"
mv target/shipping.jar shipping.jar
validate $? "Moving shipping.jar file"
sed -i "s/DOMAIN_NAME/$domain_name/g" "$script_dir/shipping.service"
validate $? "Replacing DOMAIN_NAME in shipping service"
cp "$script_dir/shipping.service" /etc/systemd/system/shipping.service
validate $? "Copying shipping.service to /etc/systemmd/system/"
dnf install mysql -y &>> $log_file
validate $? "Installing MySQL client"

# count=$(mysql -h "mysql.$domain_name" -u root -pRoboShop@1 -N -B -e "SELECT COUNT(*) FROM cities.cities;" 2>> $log_file )
# if [ -z "$count" ] || [ "$count" -eq 0 ]; then

    mysql -h "mysql.$domain_name" -uroot -pRoboShop@1 < /app/db/master-data.sql
    validate $? "Loading shipping data"

# else
#   already loaded...${Y}SKIPPING${N}"  echo -e "$(timestamp) [INFO] Master data 
# fi

# mysql -h "mysql.$domain_name" -uroot -pRoboShop@1 < /app/db/app-user.sql
# validate $? "Creating APP user"
systemctl daemon-reload &>> $log_file
validate $? "Daemon reload"
systemctl enable shipping.service &>> $log_file
validate $? "Enabling shipping.service"
systemctl start shipping.service &>> $log_file
validate $? "Starting shipping.service"
systemctl restart shipping.service &>> $log_file
validate $? "Restarting/Starting shipping.service"
echo -e "${M}$(timestamp) [INFO] Script excution to take time "$SECONDS" in seconds${N}" | tee -a $log_file
echo -e "${M}$(timestamp) [INFO] ==== Script completed Execution =====${N}" | tee -a $logs_file

