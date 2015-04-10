#!/bin/bash

vagrant destroy -f

modman remove ubuntu1410-docker
modman remove vagrant-docker-utils

if [ -f "proxy/config.yaml" ]; then
  rm proxy/config.yaml
fi

if [ -f "local-config.php" ]; then
  rm local-config.php
fi

sh bin/vagrant-up.sh auto