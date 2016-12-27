#!/bin/bash

#AWS CLI must be installed and configured before using
#This script is a pure bash means of using the AWS Route53 CLI to create a dynamic DNS updater when used with cron
#Script will check the current public ip and compare it to the ip from the last time it updated
#If it matches, logs that it checked and did not update
#Else, it logs that it is updating, pipes the ip address into a json formatted file so that it can be called from the AWS CLI and update Route53

#Need to change DNS-NAME and ZONE-ID to the DNS name you are updating and your Route53 Hosted Zone ID

now=$(date +"%m-%d-%Y-%H-%M-%S")
publicip="$(dig TXT +short o-o.myaddr.l.google.com @ns1.google.com)"
previousip=$(<lastip)
if [[ "$publicip" == "$previousip" ]]; then
  echo "${now} IP's match, not updating" >> ddnslog.txt && exit 0
else
  echo "${now} IP's do not match, updating" >> ddnslog.txt && echo "{\"Changes\": [{\"Action\": \"UPSERT\", \"ResourceRecordSet\": {\"Name\": \"DNS-NAME\", \"Type\": \"A\", \"TTL\": 300, \"ResourceRecords\": [{\"Value\": ${publicip}}]}}]}" > update-r53-dns.json && aws route53 change-resource-record-sets --hosted-zone-id ZONE-ID --change-batch file://update-r53-dns.json && echo "${publicip}" > lastip && exit 0
fi
