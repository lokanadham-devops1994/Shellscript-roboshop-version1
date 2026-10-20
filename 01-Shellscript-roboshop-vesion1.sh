#!/bin/bash
image_id="ami-0eec78ea4cbaaf5bd"
instance_type="t3.micro"
domain_name="daws-92s.shop"
hosted_zone_id="Z07721523EJLIZ4JK5SSZ"
R="\e[1;31m"
G="\e[1;32m"
Y="\e[1;33m"
M="\e[1;35m"
N="\e[0m"
for instance in $@;
do
    echo -e "${M}Create instance: ${Y}$instance${N}"
    INSTANCE_ID=$(aws ec2 run-instances \
    --image-id $image_id \
    --instance-type $instance_type \
    --count 1 \
    --security-groups "roboshop-common" "roboshop-mongodb" \
    --tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value=roboshop-$instance}]' \
	--query 'Instances[0].InstanceId' \
    --output text)
    echo -e "${M}The new instance ID is: ${Y}$INSTANCE_ID${N}" 
done