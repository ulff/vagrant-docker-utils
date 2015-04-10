#!/bin/bash

location=$(pwd)
default_container=$(vagrant global-status | grep $location/proxy | awk -F "^| default" '{print $1}')
vagrant destroy -f && vagrant destroy -f $default_container

modman remove ubuntu1410-docker
modman remove vagrant-docker-utils

if [ -f "proxy/config.yaml" ]; then
  rm proxy/config.yaml
fi

if [ -f "local-config.php" ]; then
  rm local-config.php
fi