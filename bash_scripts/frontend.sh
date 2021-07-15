#! /bin/bash

ssh_username=$ssh_username &&

project_name=$project_name &&

external_port=$external_port &&

frontend_project_path="/home/$ssh_username/$project_name" &&

apt-get update && apt-get upgrade -y &&

curl -sL https://deb.nodesource.com/setup_12.x | -E bash - &&

apt-get install -y nodejs &&

apt update &&

cd $frontend_project_path && chmod +x start.sh &&

npm install &&

npm run build &&

apt-get install supervisor -y &&

npm install -g serve &&

apt install nginx -y &&

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

cp frontend-service.conf /etc/supervisor/conf.d/ &&

rm -rf frontend-service.conf &&

rm -rf /etc/nginx/sites-enabled/default &&

rm -rf /etc/nginx/sites-available/default &&

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

cp prod.conf /etc/nginx/sites-available/ &&

ln -sf /etc/nginx/sites-available/prod.conf /etc/nginx/sites-enabled/

systemctl restart nginx &&

systemctl restart supervisor