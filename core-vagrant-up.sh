#!/bin/bash
# Set PS3 prompt

modman clone git@github.com:Sysla/ubuntu1410-docker.git
modman update-all
modman deploy-all

git submodule update --init --recursive

echo "creating proxy/config.yaml"

IP=192.168.36.10
PORT=8080
VM_HOSTNAME="devstack.dev"

PS3="Pick project to setup : "

args=("$@")

hostname=${args[0]}

if [ -z "${args[0]}" ]; then
    select hostname in devstack maritime sysla offshore offshore-mysql wntt varnish-offshore CUSTOM
    do
        break
    done
fi
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
    VM_HOSTNAME=maritime.lh
    break
    ;;
  sysla)
    IP=192.168.36.12
    PORT=8082
    VM_HOSTNAME=sysla.lh
    break
    ;;
  offshore)
    IP=192.168.36.13
    PORT=8083
    VM_HOSTNAME=offshore.lh
    break
    ;;
  offshore-mysql)
    IP=192.168.36.14
    PORT=8084
    VM_HOSTNAME=offshore-mysql
    break
    ;;
  wntt)
    IP=192.168.36.16
    PORT=8092
    VM_HOSTNAME=wntt.lh
    break
    ;;
  varnish-offshore)
    IP=192.168.36.17
    PORT=8093
    VM_HOSTNAME=varnish-offshore.lh
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

sed "s/<IP_ADDRESS>/$IP/;s/<PORT>/$PORT/" < proxy/config.yaml.TEMPLATE > proxy/config.yaml
sed "s/<HOSTNAME>/$VM_HOSTNAME/" < proxy/Vagrantfile.proxy.TEMPLATE > proxy/Vagrantfile.proxy
sed "s/, type: \"nfs\"//" < proxy/Vagrantfile.proxy > proxy/Vagrantfile.proxy

if [ -z "${args[0]}" ]; then
  vi proxy/config.yaml
fi

# Wordpress specific setup
if [ -f "local-config.php.TEMPLATE" ]; then
  if [ ! -f "local-config.php" ]; then
    echo "Creating local-config.php"

    AWS_ACCESS_KEY_ID=$(cat credentials.yml | grep AWS_ACCESS_KEY_ID | sed "s/.*://")
    if [ ! "$AWS_ACCESS_KEY_ID" ]; then
      read -p "Enter AWS_ACCESS_KEY_ID: " AWS_ACCESS_KEY_ID
    fi

    AWS_SECRET_ACCESS_KEY=$(cat credentials.yml | grep AWS_SECRET_ACCESS_KEY | sed "s/.*://")
    if [ ! "$AWS_SECRET_ACCESS_KEY" ]; then
      read -p "Enter AWS_SECRET_ACCESS_KEY: " AWS_SECRET_ACCESS_KEY
    fi

    sed "s/<AWS_ACCESS_KEY_ID>/$AWS_ACCESS_KEY_ID/;s/<AWS_SECRET_ACCESS_KEY>/$AWS_SECRET_ACCESS_KEY/" < local-config.php.TEMPLATE > local-config.php
  fi

  if [ -f "composer.json" ]; then
    if [ -d "vendor" ]; then
      rm -fr vendor
    fi
    if [ -d "wp" ]; then
      rm -fr wp
    fi
    if [ -f "composer.lock" ]; then
      rm composer.lock
    fi

    composer install -n
    composer update
  fi
fi
if [ -f "local-test-config.php.TEMPLATE" ]; then
  echo "creating local-test-config.php"
  cp local-test-config.php.TEMPLATE local-test-config.php
fi

# E2E test specific setup
if [ -f "conf.js.TEMPLATE" ]; then
  if [ ! -f "conf.js" ]; then
    echo "Creating SauceLabs credentials"

    SAUCE_LABS_USERNAME=$(cat credentials.yml | grep SAUCE_LABS_USERNAME | sed "s/.*://")
    if [ ! "$SAUCE_LABS_USERNAME" ]; then
      read -p "Enter SauceLabs Username:" SAUCE_LABS_USERNAME
    fi

    SAUCE_LABS_ACCESS_KEY=$(cat credentials.yml | grep SAUCE_LABS_ACCESS_KEY | sed "s/.*://")
    if [ ! "$SAUCE_LABS_ACCESS_KEY" ]; then
      read -p "Enter SauceLabs AccessKey:" SAUCE_LABS_ACCESS_KEY
    fi

    sed "s/<SAUCE_LABS_USERNAME>/$SAUCE_LABS_USERNAME/;s/<SAUCE_LABS_ACCESS_KEY>/$SAUCE_LABS_ACCESS_KEY/" < conf.js.TEMPLATE > conf.js
  fi
  if [ ! -f "Gruntfile.js" ]; then
    sed "s/<SAUCE_LABS_USERNAME>/$SAUCE_LABS_USERNAME/;s/<SAUCE_LABS_ACCESS_KEY>/$SAUCE_LABS_ACCESS_KEY/" < Gruntfile.js.TEMPLATE > Gruntfile.js
  fi
fi

# docker config
if [ -f ".dockercfg.TEMPLATE" ]; then
  if [ ! -f ".dockercfg" ]; then
    echo "Creating dockerhub credentials"

    DOCKER_USER_EMAIL=$(cat credentials.yml | grep DOCKER_USER_EMAIL | sed "s/.*://")
    if [ ! "$DOCKER_USER_EMAIL" ]; then
      read -p "Enter dockerhub email:" DOCKER_USER_EMAIL
    fi

    DOCKER_USER_AUTH=$(cat credentials.yml | grep DOCKER_USER_AUTH | sed "s/.*://")
    if [ ! "$DOCKER_USER_AUTH" ]; then
      read -p "Enter dockerhub auth:" DOCKER_USER_AUTH
    fi

    sed "s/<EMAIL>/$DOCKER_USER_EMAIL/;s/<AUTH>/$DOCKER_USER_AUTH/" < .dockercfg.TEMPLATE > .dockercfg
  fi
fi

# Wordpress specific setup
if [ -f "local-config.php.TEMPLATE" ]; then
  if [ -f "package.json" ]; then
    if [ -d "node_modules" ]; then
      rm -fr node_modules
    fi
    npm install --unsafe-perm
  fi
  if [ -f ".htaccess.TEMPLATE" ]; then
    sed 's#<WEBSITE_DOMAIN>#offshore.lh#;s#<WEBSITE_DOMAIN_EXITED>#offshore\\.lh#' < .htaccess.TEMPLATE > wp/.htaccess
  fi
fi

vagrant up --provider=docker --no-parallel

location=$(pwd)
default_container=$(vagrant global-status | grep $location/proxy | awk -F "^| default" '{print $1}')
vagrant ssh $default_container