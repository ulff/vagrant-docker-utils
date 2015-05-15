#!/bin/bash

location=$(pwd)
default_container=$(vagrant global-status | grep $location/proxy | awk -F "^| default" '{print $1}')
vagrant destroy -f && vagrant destroy -f $default_container

if [ -d ".modman/ubuntu1410-docker" ]; then
  modman remove ubuntu1410-docker
fi

if [ -d ".modman/vagrant-docker-utils" ]; then
  modman remove vagrant-docker-utils
fi

if [ -d ".modman/e2e-test-utils" ]; then
  modman remove e2e-test-utils
fi

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