#!/bin/bash


mongo_username="${MONGO_USERNAME:-admin}"

mongo_password="${MONGO_PASSWORD:-changeme}"

sudo apt-get update && sudo apt-get upgrade -y &&

sudo apt install apt-transport-https ca-certificates curl gnupg-agent software-properties-common -y &&

curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add - &&

sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" &&

sudo apt update && sudo apt install docker-ce docker-ce-cli containerd.io -y &&

sudo apt update && apt list -a docker-ce &&

sudo docker pull mongo &&

sudo docker run \
  -d \
  -it \
  -u root \
  -p 27017:27017 \
  --name mongo \
  --restart always \
  -v `pwd`/data/mongo:/data/db \
  -e MONGO_INITDB_ROOT_USERNAME=$mongo_username \
  -e MONGO_INITDB_ROOT_PASSWORD=$mongo_password \
  mongo
