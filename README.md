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
    "aws_access_key": "***REMOVED_AWS_KEY***",
    "aws_secret_access_key": "***REMOVED_AWS_SECRET***",
    "aws_region": "us-east-1",
    "aws_source_ami": "ami-09e67e426f25ce0d7",
    "aws_instance_type": "t2.nano",
    "aws_ssh_username": "ubuntu",
    "aws_ami_name": "mongo_server_ami",
    "mongo_username": "***REMOVED_PASSWORD***",
    "mongo_password": "***REMOVED_PASSWORD***"
}
