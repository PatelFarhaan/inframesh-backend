#! /bin/bash

ssh_username=$ssh_username &&

project_name=$project_name &&

external_port=$external_port &&

backend_project_path="/home/$ssh_username/$project_name" &&

apt-get update && apt-get upgrade -y &&

apt-get install python3-pip -y &&

pip3 install virtualenv &&

apt-get install supervisor -y &&

apt update &&

apt install nginx -y &&

cd "$backend_project_path" &&

chmod +x start.sh &&

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

cp backend-service.conf /etc/supervisor/conf.d/ &&

rm -rf backend-service.conf &&

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
