#Packer

## Install Packer
1. curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -
2. sudo apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"
3. sudo apt-get update && sudo apt-get install packer


## How to Run this application without Docker:
1. Create a virtual environment using the command: 
    ```
    virtualenv venv
   ```
   
2. Actiavte the virtual environment using the command: 
    ```
    source venv/bin/activate
   ```

3. Install all the requirements: 
    ```
    pip3 install -r requirements.txt
   ```

4. Setup Redis Backend:
    ```
    ./run-redis.sh
    ```

5. Run the application:
    ```
    (venv)$ python3 app.py
   ```

6. Run the celery Worker
    ```
    (venv)$ celery worker -A app.celery --loglevel=info
    ```


## Test Case

1. 1st Request Details:
```
URL: http://***REMOVED_IP***:5000/machine-image

Method: POST

Body:
{
    "ports": [{
        "port": "3000",
        "tag": "port 1",
        "description": "fcgvhbn"
    }],
    "application": "frontend",
    "language": "reactjs",
    "version": "16.0",
    "cloud_provider": "AWS",
    "cloud_region": "us-east-1",
    "cloud_access_key": "***REMOVED_AWS_KEY***", 
    "cloud_secret_key": "***REMOVED_AWS_SECRET***",
    "git_provider": "github",
    "git_personal_access_token": "***REMOVED_GITHUB_PAT***",
    "git_repo_name": "InfraMesh",
    "git_username": "patelfarhaan",
    "git_token_name": "noob",
    "source_ami": "ami-09e67e426f25ce0d7",
    "cloud_instance_type": "t2.micro",
    "os": "ubuntu",
    "cloud_project_name": "InfraMesh"
}

Sync Response:
{
    "requestId": "39676c53-6a29-473b-b72f-51c2561ea282",
    "result": "Request has been submitted Successfully",
    "taskId": "390e6b45-c2d0-402b-96ce-1ed801aa3ead"
}
```

2. 2nd Request Details
```
URL: http://***REMOVED_IP***:5000/status/0ec7ea48-4892-456f-8c0a-5cc1a38b1d66

Method: GET

The above path params is nothing but Task Id, that you'll get in the response of 1st Request 

Intermediate Response:
{
    "result": {
        "requestId": "39676c53-6a29-473b-b72f-51c2561ea282",
        "taskId": "390e6b45-c2d0-402b-96ce-1ed801aa3ead"
    },
    "state": "PROGRESS"
}

Success Response: 
{
    "result": {
        "result": {
            "amiId": "ami-06b8e78a6b9113772",
            "msg": "AMI has been Created Successfully!!!",
            "requestId": "39676c53-6a29-473b-b72f-51c2561ea282",
            "taskId": "390e6b45-c2d0-402b-96ce-1ed801aa3ead"
        }
    },
    "state": "SUCCESS"
}

```


## Build Manually
packer build -var access_key=***REMOVED_AWS_KEY*** -var secret_access_key=***REMOVED_AWS_SECRET*** -var region=us-east-1 -var source_ami=ami-09e67e426f25ce0d7 -var instance_type=t2.micro -var ssh_username=ubuntu -var ami_name=nginx_server_ami -var project_name=InfraMesh -var github_username=patelfarhaan -var github_token=***REMOVED_GITHUB_PAT*** -var repo_name=InfraMesh -var github_clone_service_sh_path=/home/karza/workspace/packer/inframesh-backend-local/bash_scripts/github_clone_service.sh -var external_port=5678 -var sh_path=/home/karza/workspace/packer/inframesh-backend-local/bash_scripts/backend.sh /home/karza/workspace/packer/inframesh-backend-local/amazon.json