#!/bin/bash
#
# File: Installer.sh
# Description: Installs the Jazz serverless framework from Centos7 ec2-instance.
#
# ---------------------------------------------
# Usage:
# ---------------------------------------------
# To Installer, run:
# ./Installer -b branch_name
# ---------------------------------------------
#Spin wheel
spin_wheel()
{
	RED='\033[0;31m'
	GREEN='\033[0;32m'
	NC='\033[0m'

	pid=$1 # Process Id of the previous running command
	message=$2
	spin='-\|/'
	printf "\r$message...."
	i=0

	while ps -p $pid > /dev/null
	do
	  #echo $pid $i
	  i=$(( (i+1) %4 ))
	  printf "\r${GREEN}$message....${spin:$i:1}"
	  sleep .05
	done

	wait "$pid"
	exitcode=$?
	if [ $exitcode -gt 0 ]
	then
		printf "\r${RED}$message....Failed${NC}\n"
		exit
	else
		printf "\r${GREEN}$message....Completed${NC}\n"

	fi
}
trap 'printf "${RED}\nCancelled....\n${NC}"; exit' 2
trap '' 20

# Installation directory
INSTALL_DIR=`pwd`
REPO_PATH=$INSTALL_DIR/jazz-installer

# Log file to record the installation logs
LOG_FILE_NAME=installer_setup.out
LOG_FILE=`realpath $INSTALL_DIR/$LOG_FILE_NAME`
JAZZ_BRANCH=$branch

function install_packages_silent () {
  # Download and Installing Softwares required for Jazz Installer
  # 1. GIT
  # 2. Java Jdk - 8u112-linux-x64
  # 3. Unzip
  # 4. AWSCLI
  # 5. Terraform - 0.9.11
  # 6. JQ - 1.5
  # 7. Atlassian CLI - 6.7.1

  # Install git
  sudo yum install -y git >>$LOG_FILE&
  spin_wheel $! "Installing git"

  # Download and Install java
  curl -v -j -k -L -H "Cookie: oraclelicense=accept-securebackup-cookie" http://download.oracle.com/otn-pub/java/jdk/8u131-b11/d54c1d3a095b4ff2b6607d096fa80163/jdk-8u131-linux-x64.rpm -o jdk-8u112-linux-x64.rpm >>$LOG_FILE 2>&1&
  spin_wheel $! "Downloading java"

  sudo rpm -ivh --force ./jdk-8u112-linux-x64.rpm >>$LOG_FILE 2>&1&
  spin_wheel $! "Installing java"

  sudo rm -rf jdk-8u112-linux-x64.rpm

  # Download and Install unzip
  sudo yum install -y unzip >>$LOG_FILE 2>&1&
  spin_wheel $! "Installing unzip"

  # Create a temporary folder .
  # Here we will have all the temporary files needed and delete it at the end
  sudo rm -rf $INSTALL_DIR/jazz_tmp
  mkdir $INSTALL_DIR/jazz_tmp

  # Download and Install awscli
  sudo curl -L https://s3.amazonaws.com/aws-cli/awscli-bundle.zip -o $INSTALL_DIR/jazz_tmp/awscli-bundle.zip >> $LOG_FILE 2>&1 &
  spin_wheel $! "Downloading  awscli bundle"
  sudo rm -rf $INSTALL_DIR/jazz_tmp/awscli-bundle
  sudo unzip $INSTALL_DIR/jazz_tmp/awscli-bundle.zip -d $INSTALL_DIR/jazz_tmp>>$LOG_FILE 2>&1 &
  spin_wheel $! "Unzipping  awscli bundle"
  sudo rm -rf /usr/local/aws
  sudo rm -f /usr/local/bin/aws

  cd $INSTALL_DIR/jazz_tmp/awscli-bundle/
  sudo ./install -i /usr/local/aws -b /usr/local/bin/aws >>$LOG_FILE 2>&1 &
  spin_wheel $! "Installing  awscli bundle"
  cd $INSTALL_DIR/

  #Download and Install Terraform
  sudo curl -v -L https://releases.hashicorp.com/terraform/0.9.11/terraform_0.9.11_linux_amd64.zip?_ga=2.191030627.850923432.1499789921-755991382.1496973261 -o $INSTALL_DIR/jazz_tmp/terraform.zip >>$LOG_FILE 2>&1 &
  spin_wheel $! "Downloading terraform"
  sudo unzip -o $INSTALL_DIR/jazz_tmp/terraform.zip -d /usr/bin>>$LOG_FILE 2>&1 &
  spin_wheel $! "Installing terraform"

  #Downloading and Install atlassian-cli
  sudo curl -L https://bobswift.atlassian.net/wiki/download/attachments/16285777/atlassian-cli-6.7.1-distribution.zip -o $INSTALL_DIR/jazz_tmp/atlassian-cli-6.7.1-distribution.zip >>$LOG_FILE 2>&1 &
  spin_wheel $! "Downloading atlassian-cli"
  sudo unzip -o $INSTALL_DIR/jazz_tmp/atlassian-cli-6.7.1-distribution.zip  >>$LOG_FILE 2>&1 &
  spin_wheel $! "Installing atlassian-cli"

  #Get Jazz Installer code base
  sudo rm -rf jazz-installer
  git clone -b $JAZZ_BRANCH https://github.com/tmobile/jazz-installer.git >>$LOG_FILE 2>&1 &
  spin_wheel $! "Downloading jazz Installer"

  #Download and Install wget
  sudo yum install -y wget >>$LOG_FILE 2>&1 &
  spin_wheel $! "Downloading and install wget"

  #Download and install pip
  sudo wget -q https://bootstrap.pypa.io/get-pip.py
  sudo python get-pip.py >>$LOG_FILE 2>&1 &
  spin_wheel $! "Downloading and install pip"

  #Download and install paramiko
  sudo pip install paramiko >>$LOG_FILE 2>&1 &
  spin_wheel $! "Downloading and install paramiko"
}

function install_packages_verbose () {
  # Download and Installing Softwares required for Jazz Installer
  # 1. GIT
  # 2. Java Jdk - 8u112-linux-x64
  # 3. Unzip
  # 4. AWSCLI
  # 5. Terraform - 0.9.11
  # 6. JQ - 1.5
  # 7. Atlassian CLI - 6.7.1

  # Install git
  sudo yum install -y git | tee -a $LOG_FILE

  # Download and Install java
  curl -v -j -k -L -H "Cookie: oraclelicense=accept-securebackup-cookie" http://download.oracle.com/otn-pub/java/jdk/8u131-b11/d54c1d3a095b4ff2b6607d096fa80163/jdk-8u131-linux-x64.rpm -o jdk-8u112-linux-x64.rpm | tee -a $LOG_FILE
  sudo rpm -ivh --force ./jdk-8u112-linux-x64.rpm | tee -a $LOG_FILE
  sudo rm -rf jdk-8u112-linux-x64.rpm

  # Download and Install unzip
  sudo yum install -y unzip | tee -a $LOG_FILE

  # Create a temporary folder .
  # Here we will have all the temporary files needed and delete it at the end
  sudo rm -rf $INSTALL_DIR/jazz_tmp
  mkdir $INSTALL_DIR/jazz_tmp

  # Download and Install awscli
  sudo curl -L https://s3.amazonaws.com/aws-cli/awscli-bundle.zip -o $INSTALL_DIR/jazz_tmp/awscli-bundle.zip | tee -a $LOG_FILEs
  sudo rm -rf $INSTALL_DIR/jazz_tmp/awscli-bundle
  sudo unzip $INSTALL_DIR/jazz_tmp/awscli-bundle.zip -d $INSTALL_DIR/jazz_tmp | tee -a $LOG_FILE
  sudo rm -rf /usr/local/aws
  sudo rm -f /usr/local/bin/aws

  cd $INSTALL_DIR/jazz_tmp/awscli-bundle/
  sudo ./install -i /usr/local/aws -b /usr/local/bin/aws | tee -a $LOG_FILE
  cd $INSTALL_DIR/

  #Download and Install Terraform
  sudo curl -v -L https://releases.hashicorp.com/terraform/0.9.11/terraform_0.9.11_linux_amd64.zip?_ga=2.191030627.850923432.1499789921-755991382.1496973261 -o $INSTALL_DIR/jazz_tmp/terraform.zip | tee -a $LOG_FILE
  sudo unzip -o $INSTALL_DIR/jazz_tmp/terraform.zip -d /usr/bin | tee -a $LOG_FILE

  #Downloading and Install atlassian-cli
  sudo curl -L https://bobswift.atlassian.net/wiki/download/attachments/16285777/atlassian-cli-6.7.1-distribution.zip -o $INSTALL_DIR/jazz_tmp/atlassian-cli-6.7.1-distribution.zip | tee -a $LOG_FILE
  sudo unzip -o $INSTALL_DIR/jazz_tmp/atlassian-cli-6.7.1-distribution.zip | tee -a $LOG_FILE

  #Get Jazz Installer code base
  sudo rm -rf jazz-installer
  git clone -b $JAZZ_BRANCH https://github.com/tmobile/jazz-installer.git | tee -a $LOG_FILE

  #Download and Install wget
  sudo yum install -y wget | tee -a $LOG_FILE

  #Download and install pip
  sudo wget -q https://bootstrap.pypa.io/get-pip.py
  sudo python get-pip.py | tee -a $LOG_FILE

  #Download and install paramiko
  sudo pip install paramiko | tee -a $LOG_FILE
}

# Running the selector
while [ $# -gt 0 ] ; do
  case "$1" in
    -h|--help)
    echo "Jazz-installer - Installer for Jazz serverless framework"
    echo ""
    echo "./Installer.sh [options]"
    echo ""
    echo "options:"
    echo "-h, --help                                  Describe help"
    echo "-b, --branch                                Branch to build Jazz framework from"
    echo "-v, --verbose 1|0                           Enable/Disable verbose Installer logs. Default:0(Disabled)"
    echo "-t, --tags Key=stackName,Value=production   Specify as space separated key/value pairs"
    exit 0 ;;

    -b|--branch)
    shift
    if [ ! $1 == "" ] ; then
      branch="$1"
    else
      echo "No arguments supplied for Installer script. We need atleast '-b' branch name to kickoff the Installer.sh"
      echo "Usage: ./Installer.sh -b branch_name"
      exit 1
    fi
    shift ;;

    -v|--verbose)
    shift
    if [[ ("$#" -gt 0) && ("$1" == "1") ]] || [[ ("$#" -gt 0) && ("$1" == "0") ]] ; then
      echo "Verbosity selected is: $1."
      if [ $1 == "1" ] ; then install_packages_verbose
      elif [ $1 == "0" ] ; then install_packages_silent
      fi
    else
      echo "Please specify 1 or 0. Enable/Disable verbose Installer logs. Default:0(Disabled)"
      echo "Usage: ./Installer --verbose 1"
      exit 1
    fi
    shift ;;

    -t|--tags)
    shift
    while [ "$#" -gt 0 ] ; do
      if [[ "$1" =~ Key=.*,Value=.* ]] && [[ ! "$1" =~ ";" ]]; then
        arr+=("$1")
      elif [[ "$1" =~ -* ]] ; then break
      else
        echo "Please specify tags in format: Key=stackName,Value=production"
        echo "Usage: ./Installer --tags Key=stackName,Value=production Key=department,Value=devops"
        exit 1
      fi
      shift
    done
    echo "Tags are: ${arr[@]}" ;;

    *)
    echo "Invalid flag! Please run './Installer.sh -h' to see all the available options."
    break ;;
  esac
done

#move the software install log jazz Installer
mv $LOG_FILE $REPO_PATH

#set the permissions
chmod -R +x $REPO_PATH/installscripts/*
mkdir -p $REPO_PATH/installscripts/sshkeys/dockerkeys

#Call the python script to continue installation process
cd $REPO_PATH/installscripts/wizard
sed -i "s|\"jazz_install_dir\".*$|\"jazz_install_dir\": \"$INSTALL_DIR\"|g" config.py
python ./run.py $JAZZ_BRANCH $INSTALL_DIR

#Clean up the jazz_tmp folder
sudo rm -rf $INSTALL_DIR/jazz_tmp

setterm -term linux -fore green
setterm -term linux -fore default
