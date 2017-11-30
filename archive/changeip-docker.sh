#!/bin/bash
# Changeip.sh is used to change the IP's in i2b2

### Functions
function changeips (){ 
                         echo " in changeips ... "
			 echo " ..."

                         echo " in changeips ... "
			 echo " ... "
			 echo " changeing IP from the previous ip $oldip "
			 echo " to new extenal ip $IP"


#                         cp  /var/www/html/webclient/i2b2_config_data.js /tmp
#                         cp  /var/www/html/admin/i2b2_config_data.js /tmp
#                         cp  /etc/httpd/conf.d/i2b2_proxy.conf /tmp
                         
#			 grep http  /var/www/html/webclient/i2b2_config_data.js
#                         grep http /var/www/html/admin/i2b2_config_data.js
#                         grep http /etc/httpd/conf.d/i2b2_proxy.conf
#
#                         echo "executing change with arg:$IP"
#                         sed -i -e "s/${oldip}/${IP}/" /var/www/html/webclient/i2b2_config_data.js
#                         sed -i -e "s/${oldip}/$1/" /var/www/html/admin/i2b2_config_data.js
#                         sed -i -e "s/${oldip}/$1/" /etc/httpd/conf.d/i2b2_proxy.conf

#                         grep http  /var/www/html/webclient/i2b2_config_data.js
#                         grep http /var/www/html/admin/i2b2_config_data.js
#                         grep http /etc/httpd/conf.d/i2b2_proxy.conf
}

if [ -z $1 ]
   then
       if [ -f /sys/hypervisor/uuid ] && [ `head -c 3 /sys/hypervisor/uuid` == ec2 ]; then
             AWS="yes"
  	     echo "You did not pass in an IP address to use for this changeip program."
     	     echo "This instance is running on AWS which requires the external address defined and "
     	     echo "passed into the program. Without defining a external IP address the script will "
 	     echo "use the private IP address which will not be accessable via the internet"
     	     echo " "
     	     echo "Please exit and pass a P1 variable into the program via ...."
     	     echo " ....  sudo sh changeip.sh 123.456.789.123 ...." 
       else
             AWS="no"
	     IP=$(ip addr | grep 'state UP' -A2 | tail -n1 | grep -oP '\d+\.\d+\.\d+\.\d+' | head -1) 
	     echo " "
	     echo "You did not pass in an IP address to use for this program."
	     echo "This instance will use the current interal address for this process which is"
   	     echo "  ....  $IP  ...."
     	     echo " "
     	     echo "If this IP address is incorrect, Please exit and pass a P1 variable into the program via ... " 
    	     echo "     .... run_docker_network.sh 123.456.789.123  ...." 
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
     echo "Using given IP to compare against current IP configuration: $1"
     echo " "
  fi


  var1=`docker exec i2b2-web /bin/bash -c " grep Reverse /etc/httpd/conf.d/i2b2_proxy.conf | grep -oP '\d+\.\d+\.\d+\.\d+' | head -1) '"


if [ ${var} = ${IP} ] 
   then
	echo "$IP and $var1 are the same"
   else 

	echo "$IP and $var1 are NOT the same"
	echo "$IP and $var1 are NOT the same"
	echo "$IP and $var1 are NOT the same"

	
   read -p "Do you want to update IP's (yes or no)" choice
   case "$choice" in
	 Yes|YES|yes|y) echo "Yes, update the IPs"
		 echo " Updating"

####		 changeips
                 exit
		 ;;
	 No|NO|no|n)    echo "No, do not change the IPs";;
	 *) echo "Bad choice" ;;
   esac
fi





echo "running prescript with arg:$1"
sed -i -e "s/localhost/$1/" /var/www/html/webclient/i2b2_config_data.js
sed -i -e "s/localhost/$1/" /var/www/html/admin/i2b2_config_data.js
sed -i -e "s/localhost/$1/" /etc/httpd/conf.d/i2b2_proxy.conf
