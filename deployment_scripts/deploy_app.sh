#!/bin/bash


cd /home/ubuntu/inframesh-backend/

virtualenv venv &&

pip3 install -r requirements.txt &&

sudo chmod +x start.sh

sudo supervisorctl restart inframesh-backend-service