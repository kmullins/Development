

#var1=`docker exec i2b2-web /bin/bash -c " grep Reverse /etc/httpd/conf.d/i2b2_proxy.conf"`
#var2=`docker exec i2b2-web /bin/bash -c " grep urlCellPM /var/www/html/webclient/i2b2_config_data.js"`
#var3=`docker exec i2b2-web /bin/bash -c " grep urlCellPM /var/www/html/admin/i2b2_config_data.js"


var1=`grep Reverse /home/kmullins/tmp/ip-test.txt | grep -oP '\d+\.\d+\.\d+\.\d+'`
var2=` grep urlCellPM /home/kmullins/tmp/ip-test.txt | grep -oP '\d+\.\d+\.\d+\.\d+'`


echo $var1
echo $var2

