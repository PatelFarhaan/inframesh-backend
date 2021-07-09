#!/bin/bash

grafana_email="test"

grafana_plugins="grafana-piechart-panel" # seperated by ,

grafana_password="***REMOVED***"

grafana_dir=/home/ubuntu/data/grafana

prometheus_dir=/home/ubuntu/data/prometheus

# check whether the prometheus.yml file exists
if [[ ! -f "$prometheus_dir/prometheus.yml" ]];
then
    echo "prometheus.yml does not exist in $prometheus_dir/prometheus.yml"
    exit 1
fi

sudo apt-get update && sudo apt-get upgrade -y &&

sudo apt install apt-transport-https ca-certificates curl gnupg-agent software-properties-common -y &&

curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add - &&

sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" &&

sudo apt update && sudo apt install docker-ce docker-ce-cli containerd.io -y &&

sudo apt update && apt list -a docker-ce &&

sudo docker pull quay.io/prometheus/node-exporter &&

sudo docker pull prom/prometheus &&

sudo docker pull grafana/grafana:latest &&

sudo docker run \
   -d \
   -it \
   -p 127.0.0.1:9100:9100 \
   --pid="host" \
   --name node_exporter \
   quay.io/prometheus/node-exporter:latest &&

sudo docker run \
   -d \
   -it \
   --restart always \
   --name prometheus \
   -p 127.0.0.1:9090:9090 \
   -v "$prometheus_dir/prometheus.yml":/etc/prometheus/prometheus.yml \
   prom/prometheus &&

mkdir "$grafana_dir" &&

sudo chown -R 472:472 $grafana_dir

sudo docker run \
   -d \
   -it \
   -p 3000:3000 \
   --name=grafana \
   --restart always \
   -v "$grafana_dir:/var/lib/grafana" \
   -e "GF_SECURITY_ADMIN_USER=$grafana_email" \
   -e "GF_SECURITY_ADMIN_PASSWORD=$grafana_password" \
   -e "GF_INSTALL_PLUGINS=$grafana_plugins" \
   grafana/grafana &&

echo "Done"


sudo docker run \
   -d \
   -it \
   -p 3000:3000 \
   --name=grafana \
   --restart always \
   -v /home/ubuntu/data/grafana:/var/lib/grafana \
   -e "GF_SECURITY_ADMIN_USER=farhaan" \
   -e "GF_SECURITY_ADMIN_PASSWORD=farees" \
   -e "GF_INSTALL_PLUGINS=grafana-piechart-panel" \
   grafana/grafana


# Make sure to place the prometheus.yml file of plugins to download: https://grafana.com/grafana/dashboards/6126

# have a text field in download plugins, will need a service which will query grafana plugins and see if tis exists
# and then user will be able to download it: https://grafana.com/api/plugins?orderBy=weight&direction=asc&filter=pi
# and frontend should be something like this: https://grafana.com/grafana/plugins/?utm_source=grafana_plugin_list&search=pi

# Can also search for dashboards like plugins: https://grafana.com/grafana/dashboards?search=node_exporter
