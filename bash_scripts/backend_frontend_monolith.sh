#! /bin/bash

# Starting Backend Service
current_path=`pwd` &&

back_end_project_name="webapp" &&

frontend_project_name="infrasketch" &&

nginx_env="dev.conf" &&

backend_project_path="/home/ubuntu/$back_end_project_name" &&

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

deactivate &&

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

sudo cp "nginx/$nginx_env" /etc/nginx/sites-available/ &&

sudo ln -sf "/etc/nginx/sites-available/$nginx_env" /etc/nginx/sites-enabled/ &&

cd "$current_path" &&


# Starting Frontend Service
frontend_project_path="/home/ubuntu/$frontend_project_name" &&

sudo apt-get update && sudo apt-get upgrade -y &&

curl -sL https://deb.nodesource.com/setup_12.x | sudo -E bash - &&

sudo apt-get install -y nodejs &&

sudo apt update &&

cd $frontend_project_path && sudo chmod +x start.sh &&

npm install &&

npm run build &&

sudo npm install -g serve &&

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

sudo systemctl restart nginx &&

sudo systemctl restart supervisor



# Backend:
  # Make sure start.sh is present in the branch and has the Gunicorn config set as:
  # cd /home/ubuntu/webapp &&
  # source venv/bin/activate &&
  # gunicorn --workers=2 --threads=4 --bind=0.0.0.0:5000 app:app
  # workers = 2 * no_of_cores
  # therads = (total_no_of_threads_in_a_core) or (no_of_cores * 2)


# Frontend:
  # Make sure start.sh is present in the branch and has the config set as:
  # serve -s build -l 3000
