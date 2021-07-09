#! /bin/bash

project_name="infrasketch" &&

nginx_env="dev.conf" &&

frontend_project_path="/home/ubuntu/$project_name" &&

sudo apt-get update && sudo apt-get upgrade -y &&

curl -sL https://deb.nodesource.com/setup_12.x | sudo -E bash - &&

sudo apt-get install -y nodejs &&

sudo apt update &&

cd $frontend_project_path && sudo chmod +x start.sh &&

npm install &&

npm run build &&

sudo apt-get install supervisor -y &&

sudo npm install -g serve &&

sudo apt install nginx -y &&

echo "
[program:frontend-service]
directory=$frontend_project_path
command=/bin/bash -E -c ./start.sh
autostart=true
autorestart=true
stopsignal=INT
stopasgroup=true
killasgroup=true
" > frontend-service.conf &&

sudo cp -u frontend-service.conf /etc/supervisor/conf.d/ &&

sudo rm -rf frontend-service.conf &&

sudo rm -rf /etc/nginx/sites-enabled/default &&

sudo rm -rf /etc/nginx/sites-available/default &&

sudo cp -u "nginx/$nginx_env" /etc/nginx/sites-available/ &&

sudo ln -sf "/etc/nginx/sites-available/$nginx_env" /etc/nginx/sites-enabled/

sudo systemctl restart nginx &&

sudo systemctl restart supervisor



# Make sure start.sh is present in the branch and has the config set as:
# serve -s build -l 3000
