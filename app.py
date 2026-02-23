import os
import re
import json
import time
import uuid
import requests
import packer_process
from flask_cors import CORS
from flask import Flask, jsonify, request, Response
from flask import session, flash, redirect, url_for, jsonify
from celery import Celery, current_task


app = Flask(__name__)
app.config['SECRET_KEY'] = os.environ.get('SECRET_KEY', 'change-me-in-production')

#Enable CORS
CORS(app)

packer_exec_path = os.environ.get('PACKER_EXEC_PATH', '/usr/bin/packer')

AWS_AMI_PATTERN = "(?i)\\b[a-z]+-[a-z0-9]+"
dir_path = os.path.dirname(os.path.realpath(__file__))


# Celery configuration
app.config['CELERY_BROKER_URL'] = os.environ.get('CELERY_BROKER_URL', 'redis://localhost:6379/0')
app.config['CELERY_RESULT_BACKEND'] = os.environ.get('CELERY_RESULT_BACKEND', 'redis://localhost:6379/0')

# Initialize Celery
celery = Celery(app.name, broker=app.config['CELERY_BROKER_URL'])
celery.conf.update(app.config)


@app.route("/ping", methods=['GET'])
def ping():
    return jsonify({
        "response": "Working!!!"
    })


@app.route("/get-region", methods=["POST"])
def get_region():
    input_data = request.get_json()
    if not input_data:
        return jsonify({
            "result": False,
            "message": "no input data found",
            "data": None
        })
    cloud = input_data.get("cloud")

    if cloud not in ["AWS", "GCP", "AZURE"]:
        return jsonify({
            "result": False,
            "message": "cloud provider not supported",
            "data": None
        })

    if cloud == "AWS":
        aws_region_file = json.load(open("./utilities/aws/regions.json", "r"))
        if aws_region_file:
            regions = aws_region_file.get("Regions")
            if regions:
                response = [region.get("RegionName") for region in regions]
                return jsonify({
                    "result": True,
                    "message": "cloud provider found",
                    "data": response
                })

    return jsonify({
        "result": False,
        "message": "regions not found",
        "data": None
    })

    # Todo: write the same function for gcp and azure


@app.route("/get-ami", methods=["POST"])
def get_ami():
    input_data = request.get_json()
    if not input_data:
        return jsonify({
            "result": False,
            "message": "no input data found",
            "data": None
        })
    cloud = input_data.get("cloud")
    type = input_data.get("type")

    if cloud not in ["AWS", "GCP", "AZURE"] and \
            type not in ["ubuntu"]:
        return jsonify({
            "result": False,
            "message": "cloud provider not supported",
            "data": None
        })

    if cloud == "AWS":
        amis = json.load(open("./utilities/aws/amis.json", "r"))
        if amis:
            amis_type = amis.get(type)
            if amis_type:
                response = [ami for ami in amis_type]
                return jsonify({
                    "result": True,
                    "message": "ami found",
                    "data": response
                })

    return jsonify({
        "result": False,
        "message": "regions not found",
        "data": None
    })

    # Todo: write the same function for gcp and azure


@app.route("/validate-token", methods=["POST"])
def validate_token():
    def generic_validation_function(response):
        if response.status_code == 200:
            return jsonify({
                "result": True,
                "message": "token is valid",
                "data": None
            })
        else:
            return jsonify({
                "result": False,
                "message": "token is invalid",
                "data": None
            })

    input_data = request.get_json()
    if not input_data:
        return jsonify({
            "result": False,
            "message": "no input data found",
            "data": None
        })

    git_cloud = input_data.get("git_cloud")
    git_username = input_data.get("git_username")
    git_repo_name = input_data.get("git_repo_name")
    git_personal_access_token = input_data.get("git_personal_access_token")

    if not all([git_personal_access_token, git_username, git_cloud, git_repo_name]):
        return jsonify({
            "result": False,
            "message": "required fields missing",
            "data": None
        })

    if git_cloud == "GITHUB":
        request_url = f"https://api.github.com/repos/{git_username}/{git_repo_name}"
        response = requests.get(request_url, auth=(git_username, git_personal_access_token))
        return generic_validation_function(response)

    # Todo: add simillar block for gitlab and bitbucket


@app.route("/get-instance-type", methods=["POST"])
def get_instance_type():
    input_data = request.get_json()
    if not input_data:
        return jsonify({
            "result": False,
            "message": "no input data found",
            "data": None
        })
    cloud = input_data.get("cloud")

    if cloud not in ["AWS", "GCP", "AZURE"]:
        return jsonify({
            "result": False,
            "message": "cloud provider not supported",
            "data": None
        })

    if cloud == "AWS":
        instance_type_file = json.load(open("./utilities/aws/instance_type.json", "r"))
        if instance_type_file:
            instance_type = instance_type_file.get("InstanceTypes")
            if instance_type:
                response = [ instance.get("InstanceType") for instance in instance_type if instance.get("InstanceType").startswith(("t", "m"))]
                return jsonify({
                    "result": True,
                    "message": "instances found",
                    "data": response
                })
    return jsonify({
        "result": True,
        "message": "no input data found",
        "data": None
    })

    # Todo: add simillar block for GCP and Azure


@celery.task(bind=True)
def long_task(self, request_id, packerfile, var_config):
    print("Going to Process Long Running JOB !!!")
    print("var_config:: {} and the type :: {}".format(var_config, type(var_config)))
    print("packer file path:: {}".format(packerfile))
    print("exec_path :: {}".format(packer_exec_path))

    task_id = str(current_task.request.id)
    print("Request ID :: {} and the Task Id :: {}".format(request_id, task_id))
    
    # Celery task metadata is available via current_task.request

    self.update_state(state='PROGRESS', meta={'requestId': request_id, 'taskId': task_id})
    
    ### Packer Process
    p = packer_process.Packer(packerfile, vars=var_config, exec_path=packer_exec_path)
    result = p.build(debug=True, machine_readable=True)  # make this as async

    print("Going to write final console output to a file !!!")
    with open("console_{}.txt".format(request_id), "w") as console:
        console.write(str(result))

    amis = re.findall(AWS_AMI_PATTERN, str(result), flags=re.IGNORECASE)
    ami_id = amis[-1]
    msg = "AMI has been Created Successfully!!!"

    self.update_state(state='SUCCESS',meta={"amiId": ami_id})
    return {
        "result": {
            "amiId": ami_id,
            "msg": msg,
            "requestId": request_id,
            "taskId": task_id
        }
    }


@app.route('/machine-image', methods=['POST'])
def get_machine_image():
    request_id = str(uuid.uuid4())
    print("Going to process for request_id {} :: ".format(request_id))
    input_ = request.json

    # Expected JSON body: see README for request format
    cloud = input_.get("cloud_provider")
    if not cloud or cloud.upper() not in ["AWS", "GCP", "AZURE"]:
        return jsonify({
            "result": False,
            "message": "cloud provider not supported",
            "data": None
        })

    application = input_.get("application", "frontend").lower()
    var_config = dict()
    packerfile = None
    ssh_username = "ubuntu"
    if cloud.upper() == "AWS":
        #Form Config Varibles
        ssh_username = "ubuntu"
        packerfile = dir_path+ '/amazon.json'

    # Add Provider Variables:
    var_config.update({   
            "access_key": input_["cloud_access_key"],
            "secret_access_key": input_["cloud_secret_key"],
            "region": input_.get("cloud_region", "us-east-1"),
            "source_ami": input_.get("source_ami", "ami-09e67e426f25ce0d7"),
            "instance_type": input_.get("cloud_instance_type", "t2.nano"),
            "ssh_username": ssh_username,
            "ami_name": input_.get("cloud_ami_name","server_ami_{}".format(request_id)) #This should add in the input, this should be the client choice
        })

    # Add Provisioner Environment Variable for github
    github_clone_service_sh_path = dir_path +"/bash_scripts/github_clone_service.sh"

    var_config.update({
        "project_name": input_.get("cloud_project_name","InfraMesh"),
        "github_username": input_.get("git_username"),
        "github_token": input_.get("git_personal_access_token"),
        "repo_name": input_.get("git_repo_name"),
        "github_clone_service_sh_path": github_clone_service_sh_path
    })

    ports = input_.get("ports")
    external_port = None
    for port_obj in ports:
        external_port = str(port_obj.get("port"))

    if application == "backend":
        sh_path = dir_path +"/bash_scripts/backend.sh"   

        # Add Provisioner Environment Variable for Backend sh
        var_config.update({
            #"nginx_path": input_.get("nginx_path", dir_path+"/nginx" ),
            "external_port": external_port,
            "sh_path": sh_path
        })

    else:
        sh_path = dir_path +"/bash_scripts/frontend.sh"  

        # Add Provisioner Environment Variable for Backend sh
        var_config.update({
            #"nginx_path": input_.get("nginx_path", dir_path+"/nginx" ),
            "external_port": external_port,
            "sh_path": sh_path
        })

    task = long_task.apply_async((request_id, packerfile, var_config))
    task_id = task.id

    return jsonify({
            "result": "Request has been submitted Successfully",
            "requestId": request_id,
            "taskId": task_id
        })


@app.route('/status/<task_id>')
def long_task_status(task_id):
    task = long_task.AsyncResult(task_id)
    result = dict()
    try:
        result = task.info
    except:
        result = str(task.info)

    response = {
            'state': task.state,
            'result': result
        }
    return jsonify(response)


## Legacy synchronous endpoint (replaced by Celery async version above)


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000, debug=True)
