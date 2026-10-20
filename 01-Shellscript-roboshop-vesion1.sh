#!/bin/bash
image_id=ami_id="ami-0eec78ea4cbaaf5bd"
instance_type="t3.micro"
domain_name="daws-92s.shop"
hosted_zone_id="Z07721523EJLIZ4JK5SSZ"
for instance in $@;
do
    echo "Create instance: $instance"
done