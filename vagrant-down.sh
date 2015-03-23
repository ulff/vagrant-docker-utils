#!/bin/bash

# location=$(pwd)
# default_container=$(vagrant global-status | grep $location/proxy | awk -F "^| default" '{print $1}')
# vagrant destroy -f && vagrant destroy -f $default_container

modman remove ubuntu1410-docker
modmab remove vagrant-docker-utils
rm proxy/config.yaml
rm local-config.php