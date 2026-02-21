# InfraMesh Backend

A Flask-based REST API backend for the InfraMesh platform that automates the creation of cloud machine images (AMIs) using HashiCorp Packer. It accepts user-provided cloud credentials, Git repository information, and instance configuration, then orchestrates Packer builds asynchronously via Celery and Redis.

## Architecture Overview

```
+-----------+       +-------------+       +---------+       +-----------+
|  React    | REST  |   Flask     | Queue |  Celery |Packer |   AWS     |
|  Frontend |------>|   API       |------>|  Worker |------>|   AMI     |
|           |       |  (Port 5000)|       |         |       |   Build   |
+-----------+       +------+------+       +----+----+       +-----------+
                           |                   |
                    +------v------+     +------v------+
                    |   Redis     |     |   Packer    |
                    | (Broker)    |     |  (amazon.json)
                    +-------------+     +-------------+
```

## Tech Stack

- **Backend**: Python 3.x, Flask, Flask-CORS
- **Task Queue**: Celery with Redis broker
- **Image Builder**: HashiCorp Packer (JSON and HCL templates)
- **Cloud Provider**: AWS (EC2 AMI creation)
- **Git Integration**: GitHub API for repository validation
- **Deployment**: AWS CodeDeploy

## Features

- RESTful API for automated AMI creation
- Asynchronous Packer builds via Celery task queue
- Support for frontend (React, Angular, Vue) and backend (Python, Node.js, Java) applications
- Git repository validation (GitHub, with GitLab/Bitbucket planned)
- Dynamic AWS region, AMI, and instance type lookups
- Real-time build status polling
- Multiple Packer template support (JSON and HCL)

## Prerequisites

- Python 3.8+
- HashiCorp Packer
- Redis server
- AWS account with EC2 permissions
- Git personal access token (for repository cloning during AMI build)

## Quick Start

### 1. Install Dependencies

```bash
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt
```

### 2. Install Packer

```bash
curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -
sudo apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"
sudo apt-get update && sudo apt-get install packer
```

### 3. Start Redis

```bash
./run-redis.sh
```

### 4. Run the Application

```bash
python3 app.py
```

### 5. Start the Celery Worker

```bash
celery worker -A app.celery --loglevel=info
```

## API Endpoints

| Method | Endpoint | Description |
|---|---|---|
| GET | `/ping` | Health check |
| POST | `/get-region` | Fetch available cloud regions |
| POST | `/get-ami` | Fetch available Ubuntu AMIs |
| POST | `/get-instance-type` | Fetch available EC2 instance types |
| POST | `/validate-token` | Validate Git personal access token |
| POST | `/machine-image` | Submit AMI build request (async) |
| GET | `/status/<task_id>` | Check build status |

### Example Request: Create Machine Image

```bash
curl -X POST http://localhost:5000/machine-image \
  -H "Content-Type: application/json" \
  -d '{
    "ports": [{"port": "3000", "tag": "web", "description": "Web server"}],
    "application": "frontend",
    "language": "reactjs",
    "version": "16.0",
    "cloud_provider": "AWS",
    "cloud_region": "us-east-1",
    "cloud_access_key": "YOUR_AWS_ACCESS_KEY",
    "cloud_secret_key": "YOUR_AWS_SECRET_KEY",
    "git_provider": "github",
    "git_personal_access_token": "YOUR_GITHUB_TOKEN",
    "git_repo_name": "your-repo",
    "git_username": "your-username",
    "source_ami": "ami-xxxxxxxxxxxxxxxxx",
    "cloud_instance_type": "t2.micro",
    "os": "ubuntu",
    "cloud_project_name": "your-project"
  }'
```

## Project Structure

```
inframesh-backend-local/
|-- app.py                     # Flask application and API routes
|-- packer_process.py          # Packer CLI wrapper
|-- github_clone.py            # Git repository cloning utility
|-- requirements.txt           # Python dependencies
|-- amazon.json                # Packer JSON template for AWS
|-- run-redis.sh               # Redis startup script
|-- start.sh                   # Application startup script
|-- appspec.yml                # AWS CodeDeploy specification
|-- bash_scripts/              # Packer provisioner shell scripts
|   |-- backend.sh             # Backend app setup script
|   |-- frontend.sh            # Frontend app setup script
|   |-- github_clone_service.sh # Git clone provisioner
|   |-- docker_deployment.sh   # Docker deployment setup
|   |-- code_deploy.sh         # CodeDeploy agent installation
|   |-- jenkins_service.sh     # Jenkins setup
|   |-- mongo_service.sh       # MongoDB setup
|   |-- server_status.sh       # Server health check
|-- hcl_scripts/               # Packer HCL templates
|   |-- amazon.pkr.hcl         # HCL-based Packer template
|-- deployment_scripts/        # CodeDeploy lifecycle hooks
|-- utilities/aws/             # AWS reference data (regions, AMIs, instance types)
|-- supporting_files/          # Additional reference data
```

## Environment Variables

| Variable | Description | Default |
|---|---|---|
| `SECRET_KEY` | Flask secret key | `change-me-in-production` |
| `CELERY_BROKER_URL` | Redis broker URL | `redis://localhost:6379/0` |

## License

MIT License
