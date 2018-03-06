#!/bin/bash
#===================================================================================
# # FILE: kmucs.sh
# # USAGE: chmod +x kmucs.sh;./kmucs.sh
# # DESCRIPTION: 표준 환경 목록에 따른 Hello World 파일
#===================================================================================

#----------------------------------------------------------------------
# path information
#----------------------------------------------------------------------
local_path="/usr/local"

#----------------------------------------------------------------------
# mirror information
#----------------------------------------------------------------------
main_mirror="ftp.daumkakao.com"
apache_mirror="ftp.daumkakao.com"
pip_mirror="ftp.daumkakao.com"

#----------------------------------------------------------------------
# sourcelist information
#----------------------------------------------------------------------
java_ppa="http://ppa.launchpad.net/webupd8team/java/ubuntu"
sbt_ppa="https://dl.bintray.com/sbt/debian"

#----------------------------------------------------------------------
# hadoop information
#----------------------------------------------------------------------
hadoop_name="hadoop"
hadoop_version="2.8.1"
hadoop_url="http://$apache_mirror/apache/hadoop/common/hadoop-2.8.1/hadoop-2.8.1.tar.gz"
hadoop_zip="hadoop-2.8.1.tar.gz"

#----------------------------------------------------------------------
# spark information
#----------------------------------------------------------------------
spark_name="spark"
spark_version="2.2.0-bin-hadoop2.7"
spark_url="http://$apache_mirror/apache/spark/spark-2.2.0/spark-2.2.0-bin-hadoop2.7.tgz"
spark_zip="spark-2.2.0-bin-hadoop2.7.tgz"

#----------------------------------------------------------------------
# log information
#----------------------------------------------------------------------
datelog=`date "+%y%m%d"`
log="Labanywhere_script_$datelog.log"
kernel_version=`uname -r`

#=== FUNCTION ==================================================================
# NAME: init_log
# DESCRIPTION: Preparing to initialize log records.
# Globals variable: log
# Globals variable: kernel_version
# Globals variable: datalog
#===============================================================================
function init_log(){
    echo "===============================================================">$log
    echo "Labanywhere script $datelog report ">>$log
    echo `date`>>$log
    echo " ">>$log
    lsb_release -a>>$log
    echo "kernerl:	$kernel_version">>$log
    echo "===============================================================">>$log
}	# ---------- end of function init_log ---------

#=== FUNCTION ==================================================================
# NAME: install_logging
# DESCRIPTION: Record installed programs.
# PARAMETER 1: program name
# Globals variable: log
#===============================================================================
function install_logging(){
    local value=$1
    echo "program installed : \"$1\"">>$log
    echo "---------------------------------------------------------------">>$log
}	# ---------- end of function install_logging ---------

#=== FUNCTION ==================================================================
# NAME: delete_logging
# DESCRIPTION: Record deleted files.
# PARAMETER 1: Compressed file in function cleanup()
# Globals variable: log
#===============================================================================
function delete_logging(){
    local value=$1
    echo "temporary file removed : \"$1\"">>$log
    echo "---------------------------------------------------------------">>$log
}	# ---------- end of function delete_logging ---------

#=== FUNCTION ==================================================================
# NAME: wget_install
# DESCRIPTION: Installing programs with wget.
#              If the program exists, wget re-downloading is stopped.
# PARAMETER 1: program name
# PARAMETER 2: progeam version
# PARAMETER 3: program URL
# PARAMETER 4: Compressed file name
# Globals variable: local_path
#===============================================================================
function wget_install(){
    local value=$1
    local value=$2
    local value=$3
    local value=$4
    if [ ! -d "$local_path/$1" ]; then
        sudo wget $3
        sudo tar xvzf $4
        sudo mv $1-$2 $local_path
        sudo ln -s $local_path/$1-$2 $local_path/$1
        install_logging $1
    else
        install_logging $1
    fi
}	# ---------- end of function wget_install ---------

#=== FUNCTION ==================================================================
# NAME: apt_install
# DESCRIPTION: Installing programs with apt.
# PARAMETER 1: program name(ex:vim)
# Globals variable: log
#===============================================================================
function apt_install(){
    local value=$1
    sudo apt-get -y install $1 | tee -a $log 2>&1
    install_logging $1 2>&1
}	# ---------- end of function apt_install ---------

#=== FUNCTION ==================================================================
# NAME: pip_install
# DESCRIPTION: Installing programs with pip.
# PARAMETER 1: program name(ex:numpy)
# Globals variable 1: pip_mirror
# Globals variable 2: log
#===============================================================================
function pip_install(){
    local value=$1
    sudo pip3 install $1 -i http://$pip_mirror/pypi/simple --trusted-host $pip_mirror | tee -a $log 2>&1
    install_logging $1 2>&1
}	# ---------- end of function pip_install ---------

#=== FUNCTION ==================================================================
# NAME: cleanup
# DESCRIPTION: deleted temporary files.
# PARAMETER 1: Compressed file
#===============================================================================
function cleanup(){
    local value=$1
    sudo rm $1 > /dev/null 2>&1
    delete_logging $1
}	# ---------- end of function cleanup ---------

#=== FUNCTION ==================================================================
# NAME: net_detect
# DESCRIPTION: detect network
#===============================================================================
function net_detect(){
    ping -q -w 1 -c 1 `ip r | grep default | cut -d ' ' -f 3` > /dev/null && echo "network connected... ok!" | tee -a $log 2>&1|| echo "network disconnected... error!" | tee -a $log 2>&1
    echo "---------------------------------------------------------------">>$log
}	# ---------- end of function net_detect ---------

#=== FUNCTION ==================================================================
# NAME: find_info
# DESCRIPTION: find computer name
#===============================================================================
function find_info(){
    sudo dmidecode | grep -A3 '^System Information' >> $log
    echo "---------------------------------------------------------------">>$log
}	# ---------- end of function find_info ---------

#----------------------------------------------------------------------
# start notify
#----------------------------------------------------------------------
notify-send  "Labanywhere" "Installation will begin. Please exit the other running programs." -u critical
#----------------------------------------------------------------------
# logging notify
#----------------------------------------------------------------------
notify-send  "Labanywhere" "All installation progress is recorded in the log file." -u critical

#----------------------------------------------------------------------
# Change apt repository
#----------------------------------------------------------------------
sudo sed -i "s/kr.archive.ubuntu.com/$main_mirror/g" /etc/apt/sources.list

#----------------------------------------------------------------------
# start logging system
#----------------------------------------------------------------------
init_log

#----------------------------------------------------------------------
# checking internet
#----------------------------------------------------------------------
net_detect

#----------------------------------------------------------------------
# find computer info
#----------------------------------------------------------------------
find_info

#----------------------------------------------------------------------
# update/upgrade system
#----------------------------------------------------------------------
sudo apt -y update && sudo apt -y upgrade

#----------------------------------------------------------------------
# Install VIM
#----------------------------------------------------------------------
apt_install vim

#----------------------------------------------------------------------
# Install gcc
#----------------------------------------------------------------------
apt_install build-essential

#----------------------------------------------------------------------
# Install Java oracle-8
#----------------------------------------------------------------------
if ! grep -q "^deb .*$java_ppa" /etc/apt/sources.list /etc/apt/sources.list.d/*; then
    sudo add-apt-repository -y ppa:webupd8team/java
fi

if ! type javac; then
    sudo apt -y update
    sudo apt install -y software-properties-common debconf-utils
    sudo echo "oracle-java8-installer shared/accepted-oracle-license-v1-1 select true" | sudo     debconf-set-selections
    sudo apt-get -y install oracle-java8-installer | tee -a $log 2>&1
fi

if type javac >/dev/null 2>/dev/null; then
    install_logging java | tee -a $log 2>&1
fi

#----------------------------------------------------------------------
# Install Eclipse
#----------------------------------------------------------------------
apt_install eclipse

#----------------------------------------------------------------------
# Install R
#----------------------------------------------------------------------
apt_install r-base

#----------------------------------------------------------------------
# Install Git
#----------------------------------------------------------------------
apt_install git

#----------------------------------------------------------------------
# Install RBTools
#----------------------------------------------------------------------
apt_install python-rbtools

#----------------------------------------------------------------------
# Install MySQL
#----------------------------------------------------------------------
sudo debconf-set-selections <<< 'mysql-server mysql-server/root_password password kmucs'
sudo debconf-set-selections <<< 'mysql-server mysql-server/root_password_again password kmucs'
apt_install mysql-server
#----------------------------------------------------------------------
# mysql password notify
#----------------------------------------------------------------------
notify-send  "Labanywhere" "The installed mysql password is \"kmucs\"."

#----------------------------------------------------------------------
# Install MySQL Workbench
#----------------------------------------------------------------------
apt_install mysql-workbench

#----------------------------------------------------------------------
# Install MySQL JDBC
#----------------------------------------------------------------------
apt_install libmysql-java

#----------------------------------------------------------------------
# Install django
#----------------------------------------------------------------------
apt_install python3-pip
sudo pip3 install --upgrade pip
pip_install django

#----------------------------------------------------------------------
# Install numpy
#----------------------------------------------------------------------
pip_install numpy

#----------------------------------------------------------------------
# Install scipy
#----------------------------------------------------------------------
pip_install scipy

#----------------------------------------------------------------------
# Install matplotlib
#----------------------------------------------------------------------
pip_install matplotlib

#----------------------------------------------------------------------
# Install pyyaml
#----------------------------------------------------------------------
pip_install pyyaml

#----------------------------------------------------------------------
# Install nltk
#----------------------------------------------------------------------
pip_install nltk

#----------------------------------------------------------------------
# Install scikit-learn
#----------------------------------------------------------------------
pip_install scikit-learn

#----------------------------------------------------------------------
# Install hadoop
# Have to set eclipse to compile hadoop in eclipse
#----------------------------------------------------------------------
wget_install $hadoop_name $hadoop_version $hadoop_url $hadoop_zip | tee -a $log

#----------------------------------------------------------------------
# Install spark
#----------------------------------------------------------------------
wget_install $spark_name $spark_version $spark_url $spark_zip | tee -a $log

#----------------------------------------------------------------------
# Enable apt over https
#----------------------------------------------------------------------
apt_install apt-transport-https

#----------------------------------------------------------------------
# Install sbt
#----------------------------------------------------------------------
if ! grep -q "^deb .*$sbt_ppa" /etc/apt/sources.list /etc/apt/sources.list.d/*; then
    echo "deb https://dl.bintray.com/sbt/debian /" | sudo tee -a /etc/apt/sources.list.d/sbt.list
fi
if ! type sbt; then
    sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv      2EE0EA64E40A89B84B2DF73499E82A75642AC823
    sudo apt update
    sudo apt-get -y install sbt | tee -a $log
fi

if type sbt >/dev/null 2>/dev/null; then
    install_logging sbt | tee -a $log
fi

#----------------------------------------------------------------------
# Cleanup temporary files
#----------------------------------------------------------------------
if [ -f "$hadoop_zip" ]; then
cleanup $hadoop_zip
fi
if [ -f "$spark_zip" ]; then
cleanup $spark_zip
fi

#----------------------------------------------------------------------
# end notify
#----------------------------------------------------------------------
notify-send  "Labanywhere" "This script completed successfully. Please reboot your computer." -u critical
