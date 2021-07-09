#!/bin/bash

# Frontend Deployment:
cd /home/ubuntu/infrasketch
dangling_images=`sudo docker images -qa -f dangling=true`
if [ -z "$dangling_images" ]
then
	echo "No Dangling images"
else
	sudo docker rmi -f $dangling_images
fi

sudo docker build -t infracode_frontend . --no-cache &&
sudo aa-remove-unknown &&


is_image_running=`sudo docker ps | grep infracode_frontend`
if [ -z "$is_image_running" ]
then
  echo "No running container found"
else
	sudo docker stop infracode_frontend
fi

sudo docker run --name infracode_frontend --rm -d -it -p 3000:80 infracode_frontend



# Backend Deployment:
#!/bin/bash


cd /home/ubuntu/webapp/

sudo bash compiled_files_cleanup.sh &&

dangling_images=`sudo docker images -qa -f dangling=true`
if [ -z "$dangling_images" ]
then
	echo "No Dangling images"
else
	sudo docker rmi -f $dangling_images
fi

sudo docker build -t webapp_flask_app . &&
sudo aa-remove-unknown &&

is_image_running=`sudo docker ps | grep webapp_flask_app`
if [ -z "$is_image_running" ]
then
  echo "No running container found"
else
	sudo docker stop webapp_flask_app
fi

sudo docker run -d --rm -it --name webapp_flask_app -p 5000:5000 webapp_flask_app

#cd /home/ubuntu/webapp/stripe_app
#sudo chmod +x start.sh &&

#sudo systemctl restart supervisor.service

