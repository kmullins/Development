IP=$1

if [[ $IP ]];then
   echo "using given IP"
else
  IP=$(ip addr | grep 'state UP' -A2 | tail -n1 | awk '{print $2}' | cut -f1  -d'/')
  echo "IP:$IP"
fi

sudo yum -y install ant tar sed bzip2 git php perl wget zip unzip httpd patch
setenforce 0
service iptables stop

source scripts/install/install.sh






PWD=$(pwd)
BASE=$PWD
LOCAL=$BASE/local

#CONFIGURE
JBOSS_HOME=$LOCAL/wildfly-9.0.1.Final
JAVA_HOME=$LOCAL/jdk1.8.0_60
AXIS_HOME=$LOCAL/axis
ANT_HOME=$LOCAL/ant
##########

echo "in INSTALL FILE PWD: $PWD"

AXIS_FILE=axis2-1.6.2-war.zip
JDK_FILE=jdk-8u92-linux-x64.tar.gz
ANT_FILE=apache-ant-1.9.6-bin.tar.bz2
JBOSS_FILE=wildfly-9.0.1.Final.zip

#check if the home directories are found as specified by user, or use default dirs
[ -d $JAVA_HOME ] || JAVA_HOME=$LOCAL/jdk1.8.0_92;#$LOCAL/${JDK_FILE/\.tar\.gz/}
[ -d $JBOSS_HOME ] || JBOSS_HOME=$LOCAL/${JBOSS_FILE/\.zip/}
[ -d $ANT_HOME ] || ANT_HOME=$LOCAL/${ANT_FILE/-bin\.tar\.bz2/}
[ -d $AXIS_HOME ] || AXIS_HOME=$LOCAL/axis

alias ant=$ANT_HOME/bin/ant
alias java="$JAVA_HOME/bin/java"

export JAVA_HOME=$JAVA_HOME

echo ">>JBOSS_HOME:$JBOSS_HOME"
[ -d $BASE/packages ] || mkdir -p $BASE/packages

echo ">>>ran config"


check_homes_for_install(){
    [ -d $LOCAL ] || mkdir $LOCAL
    [ -d $JAVA_HOME ] && echo "found JAVA_HOME:$JAVA_HOME"|| install_java
    [ -d $ANT_HOME ] && echo "found ANT_HOME:$ANT_HOME"|| install_ant
    [ -d $AXIS_HOME ] && echo "found AXIS_HOME:$AXIS_HOME"|| download_axis_jar;
    [ -d $JBOSS_HOME ] && echo "found JBOSS_HOME:$JBOSS_HOME"|| download_wildfly && install_wildfly
}

[ -f  i2b2-core-server.zip ] || wget -v https://github.com/i2b2/i2b2-core-server/archive/master.zip -O i2b2-core-server.zip

download_i2b2_source(){
  BASE=$1
  cd $BASE/packages;
  for x in i2b2-core-server i2b2-data; do
     echo " downloading $x"
     [ -f  $x.zip ] || wget -v https://github.com/i2b2/$x/archive/master.zip -O $x.zip
  done
  cd $LOCAL
}

 unzip_i2b2core(){
  [ -d $BASE/unzipped_packages ] || mkdir $BASE/unzipped_packages
  cd $BASE/unzipped_packages
  for x in $(ls ../packages/i2b2*.zip | xargs -n 1 basename); do
      f=${x/\.zip/-master}
      echo "unzipping $x from $f";
      [ -d $f ] || unzip ../packages/$x
  done

  CRC="i2b2-core-server-master/edu.harvard.i2b2.crc"
  if [ -f "$CRC/patch_crc_PDOcall" ];then
     echo "PATCH is already applied"
  else
     cp ../packages/patch_crc_PDOcall $CRC/
     cd $CRC/src/server;
     patch -p1 < ../../patch_crc_PDOcall
  fi
  cd $BASE
}

install_ant(){
  cd $BASE/packages
  if [ -f $ANT_FILE ]
       then echo "Found $ANT_FILE"
  else
    #wget http://archive.apache.org/dist/ant/binaries/$ANT_FILE
    #wget https://www.dropbox.com/s/nbt6y9t139m8nhk/apache-ant-1.9.6-bin.tar.bz2
  fi
  cd $BASE
  if [ -d $ANT_HOME ];then 
     echo "FOUND ANT_HOME:$ANT_HOME"
  else
      cd $LOCAL
      tar -xvjf $BASE/packages/$ANT_FILE												
  fi
  cd $BASE
}

download_axis_jar(){
  cd $BASE/packages
  if [ -f $AXIS_FILE ] then 
     echo ""
  else
    #wget https://www.i2b2.org/software/projects/installer/$AXIS_FILE
    #wget https://www.dropbox.com/s/9c0gjqbwssubd76/axis2-1.6.2-war.zip
  fi
  if [ -d $BASE/packages/$AXIS_FILE ]; then 
     echo "found axis dir";
  else
     cd $LOCAL
     mkdir axis
     cd axis
     echo "AF:$AXIS_FILE"
     unzip $BASE/packages/$AXIS_FILE
     cp  axis2.war axis2.zip
  fi
  cd $BASE
}


copy_axis_to_wildfly $JBOSS_HOME



copy_axis_to_wildfly(){
  [[ $1 ]] && JBOSS_HOME=$1
  if [ -d $JBOSS_HOME/standalone/deployments/i2b2.war ] ; then
     echo "axis already copied to JBOSS"
  else
     mkdir -p $JBOSS_HOME/standalone/deployments/i2b2.war
     cd "$JBOSS_HOME/standalone/deployments/i2b2.war"
     unzip $AXIS_HOME/axis2.zip
     echo ""> $JBOSS_HOME/standalone/deployments/i2b2.war.dodeploy
   fi
}

copy_axis2_to_wildfly_i2b2war(){
   [[ $1 ]] && BASE=$1
   [[ $2 ]] && JBOSS_HOME=$2
   _FILE=$JBOSS_HOME/standalone/deployments/i2b2.war/WEB-INF/conf/axis2.xml
   _FROM_FILE="$BASE/unzipped_packages/i2b2-core-server-master/edu.harvard.i2b2.server-common/etc/axis2/axis2.xml"
   cp $_FROM_FILE $_FILE
   echo "copying axis2.xml  to i2b2 jboss deploy" 
}


compile_i2b2core(){
    BASE=$1
    local BASE_CORE="$BASE/unzipped_packages/i2b2-core-server-master"
    local CONF_DIR=$BASE/conf
    local DB=postgres
    if [[ $2 ]]; then
       JBOSS_HOME=$2;
       echo "using JBOSS_HOME=$JBOSS_HOME"
    fi
    if [ $# -gt 2 ];then
       SPRING_CONF_HOME=$3
    else
       SPRING_CONF_HOME=$JBOSS_HOME
    fi
    if [ $# -gt 3 ];then
       SCP=$4 #SPRING_CONF_PATH
    else
       SCP=$JBOSS_HOME
    fi
																	        SPRING_CONF_HOME=$JBOSS_HOME
    echo "SPRING_CONF_HOME:$SPRING_CONF_HOME"
    local TAR_DIR="$BASE_CORE/edu.harvard.i2b2.server-common"
    cd $TAR_DIR
    echo "jboss.home=$JBOSS_HOME" >> "$TAR_DIR/build.properties"
    export PATH="$PATH:$ANT_HOME/bin/:$JAVA_HOME/bin:"

   
																	        ant clean dist deploy jboss_pre_deployment_setup
    copy_axis2_to_wildfly_i2b2war;
    echo "PWD:$PWD"
    
    local CELL_NAME="pm"
    local TAR_DIR="$BASE_CORE/edu.harvard.i2b2.${CELL_NAME}"
    cd $TAR_DIR
    echo "jboss.home=$JBOSS_HOME" >> "$TAR_DIR/build.properties"
    cp -rv "$CONF_DIR/$CELL_NAME"/etc-jboss/$DB/* etc/jboss/
    ant -f master_build.xml clean build-all deploy
    
    CELL_NAME="ontology"
    TAR_DIR="$BASE_CORE/edu.harvard.i2b2.${CELL_NAME}"
    cd $TAR_DIR
    echo "jboss.home=$JBOSS_HOME" >> "$TAR_DIR/build.properties"
    cp -rv "$CONF_DIR/$CELL_NAME"/etc-jboss/$DB/* etc/jboss/
    echo "edu.harvard.i2b2.ontology.applicationdir=$SCP/standalone/configuration/ontologyapp" >> "$TAR_DIR/etc/spring/ontology_application_directory.properties"
    ant -f master_build.xml clean build-all
    echo "edu.harvard.i2b2.ontology.applicationdir=$SPRING_CONF_HOME/standalone/configuration/ontologyapp" >> "$TAR_DIR/etc/spring/ontology_application_directory.properties"
    ant -f master_build.xml deploy

    export CELL_NAME="crc"
    export TAR_DIR="$BASE_CORE/edu.harvard.i2b2.${CELL_NAME}"
    cd $TAR_DIR
    echo "jboss.home=$JBOSS_HOME" >> "$TAR_DIR/build.properties"
    cp -rv "$CONF_DIR/$CELL_NAME"/etc-jboss/$DB/* etc/jboss/
    echo "edu.harvard.i2b2.crc.applicationdir=$SCP/standalone/configuration/crcapp" >> "$TAR_DIR/etc/spring/crc_application_directory.properties"
    ant -f master_build.xml clean build-all
    echo "edu.harvard.i2b2.crc.applicationdir=$SPRING_CONF_HOME/standalone/configuration/crcapp" >> "$TAR_DIR/etc/spring/crc_application_directory.properties"
    ant -f master_build.xml deploy

    export CELL_NAME="workplace"
    export TAR_DIR="$BASE_CORE/edu.harvard.i2b2.${CELL_NAME}"
    cd $TAR_DIR
    echo "jboss.home=$JBOSS_HOME" >> "$TAR_DIR/build.properties"
    cp -rv "$CONF_DIR/$CELL_NAME"/etc-jboss/$DB/* etc/jboss/
    echo "edu.harvard.i2b2.workplace.applicationdir=$SCP/standalone/configuration/workplaceapp" >> "$TAR_DIR/etc/spring/workplace_application_directory.properties"
    ant -f master_build.xml clean build-all
    echo "edu.harvard.i2b2.workplace.applicationdir=$SPRING_CONF_HOME/standalone/configuration/workplaceapp" >> "$TAR_DIR/etc/spring/workplace_application_directory.properties"
    ant -f master_build.xml deploy

    export CELL_NAME="im"
    export TAR_DIR="$BASE_CORE/edu.harvard.i2b2.${CELL_NAME}"
    cd $TAR_DIR
    echo "jboss.home=$JBOSS_HOME" >> "$TAR_DIR/build.properties"
    cp -rv "$CONF_DIR/$CELL_NAME"/etc-jboss/$DB/* etc/jboss/
    echo "edu.harvard.i2b2.$CELL_NAME.applicationdir=$SCP/standalone/configuration/im" >> "$TAR_DIR/etc/spring/im_application_directory.properties"
    ant -f master_build.xml clean build-all
    echo "edu.harvard.i2b2.workplace.applicationdir=$SPRING_CONF_HOME/standalone/configuration/imapp" >> "$TAR_DIR/etc/spring/im_application_directory.properties"
    ant -f master_build.xml deploy
}

download_wildfly(){
   cd $BASE/packages
   if [ -f $JBOSS_FILE ]
   then 
      echo "FOUND $JBOSS_FILE"
   else
      #wget http://download.jboss.org/wildfly/9.0.1.Final/wildfly-9.0.1.Final.tar.gz
      #wget https://www.dropbox.com/s/187wgnwnmglt2wd/wildfly-9.0.1.Final.zip
   fi
   cd $BASE_CORE
}

install_wildfly(){
   cd $LOCAL || echo "error local home not found"
   if [ -d $JBOSS_HOME ]
      then echo "FOUND $JBOSS_HOME"
   else
      unzip $BASE/packages/$JBOSS_FILE
      sed -i -e s/port-offset:0/port-offset:1010/  "$JBOSS_HOME/standalone/configuration/standalone.xml"
   fi
   copy_axis_to_wildfly $JBOSS_HOME
}



#check_homes_for_install $(pwd)
#download_i2b2_source $BASE
#unzip_i2b2core $BASE
#compile_i2b2core $BASE

   check_homes_for_install $(pwd)
   #download_i2b2_source $BASE
   #unzip_i2b2core $BASE
   #compile_i2b2core $(pwd)

#run_wildfly $(pwd)
#download_i2b2_source
#unzip_i2b2core
#exit
#check_homes_for_install

















echo "searching for $CRC/patch_crc_PDOcall"














download_i2b2_source $(pwd)
unzip_i2b2core $(pwd)





