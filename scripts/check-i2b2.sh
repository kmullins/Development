#!/bin/bash

var1="grep Reverse /etc/httpd/conf.d/i2b2_proxy.conf  | grep -oP '\d+\.\d+\.\d+\.\d+'"
var2="grep urlCellPM /var/www/html/webclient/i2b2_config_data.js | grep -oP '\d+\.\d+\.\d+\.\d+'"

echo " "
echo "/etc/httpd/conf.d/i2b2_proxy.com   ........  $var1"
echo "/var/www/html/webclient/i2b2_config_data ..  $var2"

echo " "
echo "IP's in postgres i2b2pm.pm_cell_data field "
echo " "
psql  -d i2b2 -c 'select * from i2b2pm.pm_cell_data;' | grep -oP '\d+\.\d+\.\d+\.\d+'

