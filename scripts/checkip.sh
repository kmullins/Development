var1=`docker exec i2b2-web /bin/bash -c "grep Reverse /etc/httpd/conf.d/i2b2_proxy.conf  | grep -oP '\d+\.\d+\.\d+\.\d+'"`
var2=`docker exec i2b2-web /bin/bash -c " grep urlCellPM /var/www/html/webclient/i2b2_config_data.js | grep -oP '\d+\.\d+\.\d+\.\d+'"`
var3=`docker exec i2b2-web /bin/bash -c " grep urlCellPM /var/www/html/admin/i2b2_config_data.js | grep -oP '\d+\.\d+\.\d+\.\d+'"`


echo "/etc/httpd/conf.d/i2b2_proxy.com   ........  $var1"
echo "/var/www/html/webclient/i2b2_config_data ..  $var2"
echo "/var/www/html/admin/i2b2_config_data .....   $var3"

sudo docker exec i2b2-pg /bin/bash -c "psql  -d i2b2 -c 'select * from i2b2pm.pm_cell_data;'" | grep -oP '\d+\.\d+\.\d+\.\d+'
sudo docker exec i2b2-pg /bin/bash -c "psql  -d i2b2 -c 'select * from i2b2pm.pm_cell_data;'" | grep -oP '\d+\.\d+\.\d+\.\d+\:\d+'


