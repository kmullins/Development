#!/bin/bash
# Identify current and new IP's and change new IP's
#
# Need to pass in the IP address as a P1 value to change IP
# Then we copy each file out of the container, modify it, and copy it back into the container.
#

if [ -z $1 ]
then

   if [ -f /sys/hypervisor/uuid ] && [ `head -c 3 /sys/hypervisor/uuid` == ec2 ]; then
       AWS="yes"
       echo "You did not pass in an IP address to use for this installation."
       echo "This instance is running on AWS which requires the external address defined and "
       echo "passed into the program. Without defining a external IP address the script will "
       echo "use the private IP address which will not be accessable via the internet"
       echo " "
       echo "Please exit and pass a P1 variable into the program via ...."
       echo " .... docker-change-ip.sh 123.456.789.123 ...." 
    else
       AWS="no"
       IP=$(ip addr | grep 'state UP' -A2 | tail -n1 | grep -oP '\d+\.\d+\.\d+\.\d+' | head -1) 
       echo " "
       echo "You did not pass in an IP address to use for this installation."
       echo "This instance will use the current interal address for this process which is"
       echo "  ....  $IP  ...."
       echo " "
       echo "If this IP address is incorrect, Please exit and pass a P1 variable into the program via ... " 
       echo "     .... docker-change-ip.sh 123.456.789.123  ...." 
       echo " "
    fi

   read -p "Do you want to EXIT and define an IP variable  (yes or no)" choice
    case "$choice" in
         Yes|YES|yes|y) echo "Yes I want to EXIT"
          echo " "
          echo "Exiting "
          echo " "
          exit  ;;
        No|NO|no|n)    echo "OK continuing with installation";;
	  *) echo "Bad choice - Try again" ;;
	esac
else
     IP=$1
     echo " "
     echo "Using given IP: $1"
     echo " "
     fi

export proxyy='/etc/httpd/conf.d/i2b2_proxy.conf'
export conff='/var/www/html/webclient/i2b2_config_data'
export dockerdir='/home/kmullins/docker'

     
   echo "..... $IP ..... "
#   echo "${proxyy}"
#   echo "${conff}"
     
     
   changeipi2b2proxyconf() { 


   echo " "
   echo " Changing IP's for /etc/httpd/conf.d/i2b2_proxy.conf "   
   echo " "


   cd ${dockerdir}
   echo " Current IP in i2b2-web container: "
   export currentip=`sudo docker exec i2b2-web /bin/bash -c "grep PassReverse  /etc/httpd/conf.d/i2b2_proxy.conf" | grep -oP '\d+\.\d+\.\d+\.\d+'` 

   echo "  ............... $currentip ....${currentip}........... "
   sudo docker cp i2b2-web:/etc/httpd/conf.d/i2b2_proxy.conf ${dockerdir}
   echo "Current IP = ${currentip}"
   echo "Changing IP from ${currentip} to ${IP} in i2b2_proxy.conf"
   sudo sed -i -e "s/${currentip}/${IP}/g"  ${dockerdir}/i2b2_proxy.conf
   export checksedip=`grep PassReverse ${dockerdir}/i2b2_proxy.conf | grep -oP '\d+\.\d+\.\d+\.\d+'`
   echo "Check IP after SED = ${checksedip}"
   if [ "${checksedip}" = "${IP}" ]; then
        echo "Copy i2b2_proxy.conf back into i2b2-web container"
        sudo docker cp /home/kmullins/docker/i2b2_proxy.conf i2b2-web:/etc/httpd/conf.d/i2b2_proxy.conf
        echo " "
        echo "Updated IP in i2b2-web container: "
        sudo docker exec i2b2-web /bin/bash -c "grep PassReverse /etc/httpd/conf.d/i2b2_proxy.conf" | grep -oP '\d+\.\d+\.\d+\.\d+'
   else
        echo " IP was not changed"
   fi
}


 changeipi2b2configdata() { 

   echo " "
   echo " Changing IP's for /var/www/webclient/i2b2_config_data.js "   
   echo " "

  checksedip=0.0.0.0
  currentip=0.0.0.0

   cd ${dockerdir}
   echo " Current IP in i2b2-web container: "
   export currentip=`sudo docker exec i2b2-web /bin/bash -c "grep urlCellPM  /var/www/html/webclient/i2b2_config_data.js" | grep -oP '\d+\.\d+\.\d+\.\d+'` 

   echo "  ..........${currentip}........... "
   sudo docker cp i2b2-web:/var/www/html/webclient/i2b2_config_data.js ${dockerdir}
   echo "Current IP = ${currentip}"
   echo "Changing IP from ${currentip} to ${IP} in i2b2_conf_data.js"
   sudo sed -i -e "s/${currentip}/${IP}/g"  ${dockerdir}/i2b2_config_data.js
   export checksedip=`grep urlCellPM ${dockerdir}/i2b2_config_data.js | grep -oP '\d+\.\d+\.\d+\.\d+'`
   echo "Check IP after SED = ${checksedip}"
   if [ "${checksedip}" = "${IP}" ]; then
        echo "Copy i2b2_config_data.js back into i2b2-web container"
        sudo docker cp /home/kmullins/docker/i2b2_config_data.js i2b2-web:/var/www/html/webclient/i2b2_config_data.js
        echo " "
        echo "Updated IP in i2b2-web container: "
        sudo docker exec i2b2-web /bin/bash -c "grep urlCellPM /var/www/html/webclient/i2b2_config_data.js" | grep -oP '\d+\.\d+\.\d+\.\d+'
   else
        echo " IP was not changed"
   fi
}

### update i2b2pm.pm_cell_data set url=replace(url,'230',230:'230:8080');
### sudo docker exec i2b2-pg /bin/bash -c "psql  -d i2b2 -c 'select * from i2b2pm.pm_cell_data;'" | grep -oP '\d+\.\d+\.\d+\.\d+\:\d+'


 changeippmcelldata() { 

   echo " "
   echo " Changing IP's for i2b2pm.pm_cell_data fields "   
   echo " "

  checksedip=0.0.0.0
  currentip=0.0.0.0

#   cd ${dockerdir}
   echo " Current IP in i2b2-pg container: "

   export currentip=`sudo docker exec i2b2-pg /bin/bash -c "psql  -d i2b2 -c 'select * from i2b2pm.pm_cell_data;'" | grep -oP '\d+\.\d+\.\d+\.\d+\:\d+'`

   echo "  ..........${currentip}........... "
   echo "Current IP = ${currentip}"
   echo "Changing IP from ${currentip} to ${IP} in i2b2_conf_data.js"

   
   sudo docker exec i2b2-pg /bin/bash -c "psql  -d i2b2 -c 'update i2b2pm.pm_cell_data set url=replace(url,'$currentip','$IP');


  checksedip=`sudo docker exec i2b2-pg /bin/bash -c "psql  -d i2b2 -c 'select * from i2b2pm.pm_cell_data;'" | grep -oP '\d+\.\d+\.\d+\.\d+\:\d+'`
#   echo "Check IP after SED = ${checksedip}"
   if [ "${checksedip}" = "${IP}" ]; then
        echo "Copy i2b2_config_data.js back into i2b2-web container"
        sudo docker cp /home/kmullins/docker/i2b2_config_data.js i2b2-web:/var/www/html/webclient/i2b2_config_data.js
        echo " "
        echo "Updated IP in i2b2-web container: "
        sudo docker exec i2b2-web /bin/bash -c "grep urlCellPM /var/www/html/webclient/i2b2_config_data.js" | grep -oP '\d+\.\d+\.\d+\.\d+'
   else
        echo " IP was not changed"


 echo "*****************************"

    changeipi2b2proxyconf
    changeipi2b2configdata
    changeippmcelldata

 echo "**********theend*******************"

