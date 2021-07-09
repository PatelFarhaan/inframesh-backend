#!/bin/bash


region="us-east-1"

sudo apt-get update && sudo apt-get upgrade -y &&

sudo apt install ruby-full -y &&

sudo apt-get install wget -y &&

cd /home/ubuntu

wget "https://aws-codedeploy-$region.s3.$region.amazonaws.com/latest/install" &&

chmod +x ./install &&

sudo ./install auto &&

sudo service codedeploy-agent start


# Get bucket name from here: https://docs.aws.amazon.com/codedeploy/latest/userguide/resource-kit.html#resource-kit-bucket-names
# Get entire commands for code deploy at: https://docs.aws.amazon.com/codedeploy/latest/userguide/codedeploy-agent-operations-install-ubuntu.html
