#! /bin/bash

ssh_username="ubuntu" &&

project_name=$project_name &&

external_backend_port=$external_backend_port &&

backend_project_path="/home/$ssh_username/$project_name" &&

sudo apt-get update && sudo apt-get upgrade -y &&

sudo apt-get install python3-pip -y &&

sudo pip3 install virtualenv &&

sudo apt-get install supervisor -y &&

sudo apt update &&

sudo apt install nginx -y &&

cd "$backend_project_path" &&

sudo chmod +x start.sh &&

virtualenv venv &&

source venv/bin/activate &&

pip3 install -r  requirements.txt &&

pip3 install gunicorn &&

echo "
[program:backend-service]
directory=$backend_project_path
command=/bin/bash -E -c ./start.sh
autostart=true
autorestart=true
stopsignal=INT
stopasgroup=true
killasgroup=true
" > backend-service.conf &&

sudo cp backend-service.conf /etc/supervisor/conf.d/ &&

sudo rm -rf backend-service.conf &&

sudo rm -rf /etc/nginx/sites-enabled/default &&

sudo rm -rf /etc/nginx/sites-available/default &&

echo "
server {
   listen        80
   server_name   - ;
   root           /var/www/;

   location /api/v1/ {
       proxy_pass http://127.0.0.1:$external_backend_port;
       proxy_http_version 1.1;
       proxy_set_header Upgrade \$http_upgrade;
       proxy_set_header Connection 'upgrade';
       proxy_set_header Host \$host;
       proxy_cache_bypass \$http_upgrade;
   }
}
" > prod.conf &&

sudo cp prod.conf /etc/nginx/sites-available/ &&

sudo ln -sf /etc/nginx/sites-available/prod.conf /etc/nginx/sites-enabled/

sudo systemctl restart nginx &&

sudo systemctl restart supervisor
