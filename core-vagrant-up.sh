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

select hostname in devstack maritime sysla offshore
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
    *)
      echo "Error: Please try again"
      ;;
  esac
done

sed "s/<HOSTNAME>/$VM_HOSTNAME/;s/<IP_ADDRESS>/$IP/;s/<PORT>/$PORT/" < proxy/config.yaml.TEMPLATE > proxy/config.yaml
vi proxy/config.yaml

# Wordpress specific setup
if [ -f "local-config.php.TEMPLATE" ]; then
  echo "creating local-config.php"
  cp local-config.php.TEMPLATE local-config.php
fi

vagrant up --provider=docker --no-parallel

location=$(pwd)
default_container=$(vagrant global-status | grep $location/proxy | awk -F "^| default" '{print $1}')
vagrant ssh $default_container