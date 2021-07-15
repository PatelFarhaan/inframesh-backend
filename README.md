#Packer


## Requirements before running the application:
Make sure to export the environment variable SECRET=<any random string> and pass this secret in the header with fieldname `secretKey`

## Install Packer
1. curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -
2. sudo apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"
3. sudo apt-get update && sudo apt-get install packer


## How to Run this application without Docker:
1. Create a virtual environment using the command: 
    ```
    virtualenv packer_env
   ```
   
2. Actiavte the virtual environment using the command: 
    ```
    source packer_env/bin/activate
   ```

3. Install all the requirements: 
    ```
    pip3 install -r requirements.txt
   ```
   
4. Run the application:
    ```
    python3 app.py
   ```

## Test Case
URL: http://localhost:5000/machine-image
headers:
	secretKey: <Need to export into the environment variable and put the same here>

Sample Body:
{
    "ports": [{
        "port": "5678",
        "tag": "port 1",
        "description": "fcgvhbn"
    }],
    "application": "backend",
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

#Build Manually
packer build -var access_key=***REMOVED_AWS_KEY*** -var secret_access_key=***REMOVED_AWS_SECRET*** -var region=us-east-1 -var source_ami=ami-09e67e426f25ce0d7 -var instance_type=t2.micro -var ssh_username=ubuntu -var ami_name=nginx_server_ami -var project_name=InfraMesh -var github_username=patelfarhaan -var github_token=***REMOVED_GITHUB_PAT*** -var repo_name=InfraMesh -var github_clone_service_sh_path=/home/karza/workspace/packer/inframesh-backend-local/bash_scripts/github_clone_service.sh -var external_port=5678 -var sh_path=/home/karza/workspace/packer/inframesh-backend-local/bash_scripts/backend.sh /home/karza/workspace/packer/inframesh-backend-local/amazon.json