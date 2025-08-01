#!/bin/bash

AMI_ID="ami-09c813fb71547fc4f"
TYPE="t2.micro"
SECURITY="sg-0d59eea9e5ef98c7e"
ZONE_ID="Z023580323RAYFGL1JQNH"

DOMAIN="daws84.fun"

INSTANCES=("payment" "mysql" "users" "cart" "dispatch" "shipping" "rabbitmq")

# for INSTANCE in ${INSTANCES[@]}
for INSTANCE in "$@"
do
    INSTANCE_id=$(aws ec2 run-instances --image-id $AMI_ID --instance-type $TYPE --security-group-ids $SECURITY --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=$INSTANCE}]" --query 'Instances[*].InstanceId' --output text)

    sleep 5

    if [ $INSTANCE != "frontend" ]
    then
        IP=$(aws ec2 describe-instances \
        --instance-ids $INSTANCE_id \
        --query 'Reservations[0].Instances[0].PrivateIpAddress' \
        --output text)
        RECORD_NAME="$INSTANCE.$DOMAIN"
    else
        IP=$(aws ec2 describe-instances \
        --instance-ids $INSTANCE_id \
        --query 'Reservations[0].Instances[0].PublicIpAddress' \
        --output text)
        RECORD_NAME="$DOMAIN"
    fi

    echo "$INSTANCE :: $IP"

    aws route53 change-resource-record-sets \
        --hosted-zone-id $ZONE_ID  \
        --change-batch '{
            "Comment": "Update A record for '"$DOMAIN"'",
            "Changes": [{
                "Action": "UPSERT",
                "ResourceRecordSet": {
                    "Name": "'$RECORD_NAME'",
                    "Type": "A",
                    "TTL" 1;
                    "ResourceRecords": [{
                        "Value": "'"$IP"'"
                    }]
                }
            }]
        
        }'
done