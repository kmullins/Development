#!/bin/bash
################

# New stuff


for x in ec2-user@52.91.118.56  ec2-user@52.201.221.251 ec2-user@184.73.215.50 centos@107.20.249.75 
do
     ssh  -i /home/kmullins/secret/i2b2key.pem $x "uname -a && df -h & top -b | head -n 5  "
    echo "   "

done     
     
for x in ubuntu@52.207.245.82  ubunut@52.200.164.25 centos@34.228.157.32 ubuntu@54.86.76.232 ubuntu@52.23.207.190 ubuntu@52.200.132.108 ubuntu@23.23.65.7 ubuntu@52.86.153.239 centos@50.16.141.243
do
     ssh  -i /home/kmullins/secret/transmart-key-pair.pem $x "uname -a && df -h & top -b | head -n 5  "
    echo "   "

done     
