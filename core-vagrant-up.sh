#!/bin/bash
# Set PS3 prompt

modman clone git@github.com:Sysla/ubuntu1410-docker.git
modman update-all
modman deploy-all

echo "creating proxy/config.yaml"

IP=192.168.36.10
PORT=8080
VM_HOSTNAME="devstack.dev"

PS3="Pick project to setup : "

select hostname in devstack maritime sysla offshore CUSTOM
do
    case $hostname in
    devstack)
      IP=192.168.36.10
      PORT=8080
      VM_HOSTNAME=devstack.dev
      break
      ;;
    maritime)
      IP=192.168.36.11
      PORT=8081
      VM_HOSTNAME=maritime.no
      break
      ;;
    sysla)
      IP=192.168.36.12
      PORT=8082
      VM_HOSTNAME=sysla.no
      break
      ;;
    offshore)
      IP=192.168.36.13
      PORT=8083
      VM_HOSTNAME=offshore.no
      break
      ;;
    CUSTOM)
      IP="<INPUT_IP>"
      PORT="<INPUT_PORT>"
      read -p "Enter hostname: " VM_HOSTNAME
      echo $VM_HOSTNAME
      echo $IP
      echo $PORT
      break
      ;;
    *)
      echo "Error: Please try again"
      ;;
  esac
done

sed "s/<IP_ADDRESS>/$IP/;s/<PORT>/$PORT/" < proxy/config.yaml.TEMPLATE > proxy/config.yaml
sed "s/<HOSTNAME>/$VM_HOSTNAME/" < proxy/Vagrantfile.proxy.TEMPLATE > proxy/Vagrantfile.proxy
vi proxy/config.yaml

# Wordpress specific setup
if [ -f "local-config.php.TEMPLATE" ]; then
  echo "creating local-config.php"
  cp local-config.php.TEMPLATE local-config.php
fi
if [ -f "local-test-config.php.TEMPLATE" ]; then
  echo "creating local-test-config.php"
  cp local-test-config.php.TEMPLATE local-test-config.php
fi

# E2E test specific setup
if [ -f "conf.js.TEMPLATE" ]; then
  if [ ! -f "conf.js" ]; then
    echo "Enter SauceLabs credentials"
    read -p "Username:" SAUCE_LABS_USERNAME
    read -p "AccessKey:" SAUCE_LABS_ACCESS_KEY

    sed "s/<SAUCE_LABS_USERNAME>/$SAUCE_LABS_USERNAME/;s/<SAUCE_LABS_ACCESS_KEY>/$SAUCE_LABS_ACCESS_KEY/" < conf.js.TEMPLATE > conf.js
  fi
  if [ ! -f "Gruntfile.js" ]; then
    sed "s/<SAUCE_LABS_USERNAME>/$SAUCE_LABS_USERNAME/;s/<SAUCE_LABS_ACCESS_KEY>/$SAUCE_LABS_ACCESS_KEY/" < Gruntfile.js.TEMPLATE > Gruntfile.js
  fi
fi

vagrant up --provider=docker --no-parallel

location=$(pwd)
default_container=$(vagrant global-status | grep $location/proxy | awk -F "^| default" '{print $1}')
vagrant ssh $default_container