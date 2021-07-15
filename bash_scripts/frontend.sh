#! /bin/bash

ssh_username="ubuntu" &&

project_name=$project_name &&

echo $project_name &&

external_port=$external_port &&

echo $external_port &&

frontend_project_path="/home/$ssh_username/$project_name" &&

echo $frontend_project_path &&

sudo apt-get update &&

sudo apt-get upgrade -y &&

curl -sL https://deb.nodesource.com/setup_16.x | sudo -E bash - &&

echo "CURL is DONE"

sudo apt-get install -y build-essential &&

sudo apt-get install -y nodejs &&

echo "NODE JS Is DONE"

sudo apt-get update &&

sudo apt install npm -y &&

cd $frontend_project_path &&

sudo chmod +x start.sh &&

echo "NPM INSTALLATION START"

sudo npm install &&

echo "NPM Installation DONE"

sudo npm run build &&

echo "NPM BUILD DONE"

sudo apt-get install supervisor -y &&

sudo npm install -g serve &&

sudo apt install nginx -y &&

echo "SUPERVSIOR NGNX DONE"

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

sudo cp frontend-service.conf /etc/supervisor/conf.d/ &&

sudo rm -rf frontend-service.conf &&

sudo rm -rf /etc/nginx/sites-enabled/default &&

sudo rm -rf /etc/nginx/sites-available/default &&

echo "ALL CONFIGURATION DONE!!!!"

echo "
server {
   listen        80;
   server_name   - ;
   root           /var/www/;

   location /api/v1/ {
       proxy_pass http://127.0.0.1:$external_port;
       proxy_http_version 1.1;
       proxy_set_header Upgrade \$http_upgrade;
       proxy_set_header Connection 'upgrade';
       proxy_set_header Host \$host;
       proxy_cache_bypass \$http_upgrade;
   }
}
" > prod.conf &&

sudo cp prod.conf /etc/nginx/sites-available/ &&

sudo ln -sf /etc/nginx/sites-available/prod.conf /etc/nginx/sites-enabled/ &&

sudo systemctl restart nginx &&

sudo systemctl restart supervisor