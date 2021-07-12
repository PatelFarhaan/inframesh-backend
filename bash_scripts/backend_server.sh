#! /bin/bash

project_name="webapp" &&

nginx_env="dev.conf" &&

backend_project_path="/home/ubuntu/$project_name" &&

sudo apt-get update && sudo apt-get upgrade -y &&

sudo apt-get install python3-pip -y &&

sudo pip3 install virtualenv &&

sudo apt-get install supervisor -y &&

sudo apt update &&

sudo apt install nginx -y &&

cd $backend_project_path && sudo chmod +x start.sh &&

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

# cp nnginx file to /etc/nginx/sites-available/

# cp "nginx/$nginx_env" /etc/nginx/sites-available/ &&

sudo cp "nginx/$nginx_env" /etc/nginx/sites-available/ &&

sudo ln -sf "/etc/nginx/sites-available/$nginx_env" /etc/nginx/sites-enabled/

sudo systemctl restart nginx &&

sudo systemctl restart supervisor



# Make sure start.sh is present in the branch and has the Gunicorn config set as:
# cd /home/ubuntu/webapp &&
# source venv/bin/activate &&
# gunicorn --workers=2 --threads=4 --bind=0.0.0.0:5000 app:app