modman clone git@github.com:Sysla/ubuntu1410-docker.git
modman update-all
modman deploy-all

echo "creating proxy/config.yaml"
cp proxy/config.yaml.TEMPLATE proxy/config.yaml
vi proxy/config.yaml

# echo "creating local-config.php"
# cp local-config.php.TEMPLATE local-config.php

# vagrant up --provider=docker --no-parallel

# location=$(pwd)
# default_container=$(vagrant global-status | grep $location/proxy | awk -F "^| default" '{print $1}')
# vagrant ssh $default_container