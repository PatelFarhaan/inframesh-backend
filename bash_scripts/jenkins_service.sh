#!/bin/bash


jenkins_dir=/home/ubuntu/data/jenkins
plugin_dir="$jenkins_dir/plugins"
list_of_plugins_to_download=(
  "aws-java-sdk"
  "codedeploy"
)

sudo apt-get update && sudo apt-get upgrade -y &&

sudo apt install apt-transport-https ca-certificates curl gnupg-agent software-properties-common -y &&

curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add - &&

sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" &&

sudo apt update && sudo apt install docker-ce docker-ce-cli containerd.io -y &&

sudo apt update && apt list -a docker-ce &&

sudo docker pull jenkinsci/blueocean &&

sudo docker run \
  -d \
  -it \
  -u root \
  -p 8081:8080 \
  --name jenkins \
  --restart always \
  -v "$jenkins_dir":/var/jenkins_home \
  -v /var/run/docker.sock:/var/run/docker.sock \
  jenkinsci/blueocean &&

while [ ! "$(sudo ls "$jenkins_dir/secrets/initialAdminPassword")" ];
do
    sleep 20
done


download_plugin() {
  if [[ -f $(sudo ls "$plugin_dir/$1.hpi") ]] || [[ -f $(sudo ls "$plugin_dir/$1.jpi") ]]; then
    echo "Skipped: $1 (already installed)"
    return 0
  else
    echo "Installing: $1"
    sudo wget -P "$plugin_dir" "https://updates.jenkins-ci.org/download/plugins/$1/latest/$1.hpi"
    return 0
  fi
}


for plugin in "${list_of_plugins_to_download[@]}"
do
  download_plugin "$plugin"
done

sudo docker restart jenkins &&

sudo cat "$jenkins_dir/secrets/initialAdminPassword"

# Name of plugins to download: https://plugins.jenkins.io/
