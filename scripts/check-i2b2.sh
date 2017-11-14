#!/bin/bash

webcl=/var/www/html/webclient
wildf=/opt/local/i2b2-quickstart/local/wildfly-9.0.1.Final
webht=/etc/httpd/conf.d/
IP=$(ip addr | grep 'state UP' -A2 | tail -n1 | awk '{print $2}' | cut -f1  -d'/')
selinuxstatus=`getenforce`


echo " Checking Selinux ..."
if [[ "$selinuxstatus" == "disabled" ]]
then
    echo " Selinux is set to $selinuxstatus"
else
    echo " Selinux is disabled"
fi

echo "  "
echo "The current IP Address is ... $IP"
if [[ `grep "$IP"  $webcl/index.php` ]]
then
   echo "Found $IP in $webcl/index.php"
   grep "$IP"  $webcl/index.php
else
   echo "$IP not found in $webcl"
   echo "Status is $? "
fi

echo " "
echo "Checking ajp port in standalone.xml:"
if [[ `grep "9009"  $wildf/standalone/configuration/standalone.xml` ]]
then
   echo "Found ajp 9009 in $wildf/standalone/configuration/standalone.xml"
   grep "9009"  $wildf/standalone/configuration/standalone.xml
else
   echo "apj 9009 not found in standalone.xml"
   echo "Status is $? "
fi

echo " "
echo "Checking ajp port in i2b2_proxy.conf"
if [[ `grep "ajp"  $webht/i2b2_proxy.conf` ]]
then
   echo "Found ajp in $webht/i2b2_proxy.conf"
  grep "ajp"  $webht/i2b2_proxy.conf
else
   echo "apj not found in $webht/i2b2_proxy.conf"
fi
