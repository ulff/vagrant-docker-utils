#!/bin/bash

location=$(pwd)
default_container=$(vagrant global-status | grep $location/proxy | awk -F "^| default" '{print $1}')
vagrant destroy -f && vagrant destroy -f $default_container

modman remove ubuntu1410-docker
modman remove vagrant-docker-utils
modman remove e2e-test-utils

if [ -f "proxy/config.yaml" ]; then
  rm proxy/config.yaml
fi

if [ -f "local-config.php" ]; then
  rm local-config.php
fi

if [ -f ".dockercfg" ]; then
  rm .dockercfg
fi

if [ -f "conf.js" ]; then
  rm conf.js
fi

if [ -f "Gruntfile.js" ]; then
  rm Gruntfile.js
fi