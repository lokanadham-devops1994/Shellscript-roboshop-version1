#!/bin/bash
# Configuration Variables
image_id="ami-0055977a6e828a4f4"
instance_type="t3.micro"
domain_name="daws-92s.shop"
hosted_zone_id="Z07721523EJLIZ4JK5SSZ"
# Color Codes
R="\e[1;31m"
G="\e[1;32m"
Y="\e[1;33m"
M="\e[1;35m"
N="\e[0m"
# timestamp idenfication for shellscript
timestamp(){
    date +"%F %T"
}
echo -e "${M}$(timestamp)${N} ${Y}Script excution started ${N}" 
# Condition loop exection
for instance in $@;
do
    echo -e "${M}Create instance:${Y}$instance${N}"
# EC2 instance Creation
INSTANCE_ID=$(aws ec2 run-instances \
        --image-id $image_id \
        --instance-type $instance_type \
        --count 1 \
        --security-groups "roboshop-common" "roboshop-$instance" \
        --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=roboshop-$instance}]" \
        --query 'Instances[0].InstanceId' \
        --output text)
    echo -e "${M}Instane-Name:"${G}$instance ID:${Y}$INSTANCE_ID${N}""
    if [[ "$Instance" != "frontend" ]]; then
        IP=$(aws ec2 describe-instances \
        --instance-ids $INSTANCE_ID \
        --query 'Reservations[*].Instances[*].PrivateIpAddress' \
        --output text)
        Route53_record="${instance}.${domain_name}"
    else
        IP=$(aws ec2 describe-instances \
            --instance-ids $INSTANCE_ID \
            --query 'Reservations[*].Instances[*].PublicIpAddress' \
            --output text)
            Route53_record="${domain_name}"
    fi
    # Update Route 53 Record
    echo -e "${M}Record:${G}$Route53_record${N}"
    aws route53 change-resource-record-sets \
        --hosted-zone-id $hosted_zone_id \
        --change-batch '{
            "Comment": "Updating A record value",
            "Changes": 
            [
                {
                "Action": "UPSERT",
                "ResourceRecordSet": 
                {
                    "Name": "'$Route53_record'",
                    "Type": "A",
                    "TTL": 1,
                    "ResourceRecords": 
                    [
                    {
                        "Value": "'$IP'"
                    }
                    ]
                }
                }
            ]
        }'
    echo -e  "${M}Route53 record updated for ${Y}$instance${N}"
echo -e "${M} $(timestamp)${N} ${Y}Script excution to take time "$SECONDS" in seconds${N}"
echo -e "${M} $(timestamp)${N} ${Y}Script excution Completed${N}"
done