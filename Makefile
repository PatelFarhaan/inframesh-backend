#<==================================================================================================>
#                                            VARIABLES
#<==================================================================================================>
DOCKER_IMAGE := inframesh-backend
DOCKER_TAG := latest

#<==================================================================================================>
#                                      LOCAL DEV TARGETS
#<==================================================================================================>

## Install Python dependencies
.PHONY: install
install:
	pip install -r requirements.txt

## Start Redis broker
.PHONY: redis
redis:
	./run-redis.sh

## Run the Flask application
.PHONY: run
run:
	python3 app.py

## Start the Celery worker
.PHONY: worker
worker:
	celery worker -A app.celery --loglevel=info

#<==================================================================================================>
#                                         DOCKER TARGETS
#<==================================================================================================>

## Build Docker image
.PHONY: docker-build
docker-build:
	docker build -t $(DOCKER_IMAGE):$(DOCKER_TAG) .

## Run Docker container
.PHONY: docker-run
docker-run:
	docker run -d -p 5000:5000 --name inframesh-backend $(DOCKER_IMAGE):$(DOCKER_TAG)

## Stop Docker container
.PHONY: docker-stop
docker-stop:
	docker stop inframesh-backend && docker rm inframesh-backend

#<==================================================================================================>
#                                        PACKER TARGETS
#<==================================================================================================>

## Validate Packer template (JSON)
.PHONY: packer-validate
packer-validate:
	packer validate amazon.json

## Validate Packer template (HCL)
.PHONY: packer-validate-hcl
packer-validate-hcl:
	cd hcl_scripts && packer validate amazon.pkr.hcl

#<==================================================================================================>
#                                        CLEANUP TARGETS
#<==================================================================================================>

## Clean compiled files and build artifacts
.PHONY: clean
clean:
	bash compiled_files_cleanup.sh
	find . -name "*.pyc" -delete
	find . -name "__pycache__" -type d -exec rm -rf {} + 2>/dev/null || true
	rm -f console_*.txt

.PHONY: help
help:
	@echo "Usage: make <target>"
	@echo ""
	@echo "Development:"
	@echo "  install              Install Python dependencies"
	@echo "  redis                Start Redis broker"
	@echo "  run                  Run Flask application"
	@echo "  worker               Start Celery worker"
	@echo ""
	@echo "Docker:"
	@echo "  docker-build         Build Docker image"
	@echo "  docker-run           Run container on port 5000"
	@echo "  docker-stop          Stop and remove container"
	@echo ""
	@echo "Packer:"
	@echo "  packer-validate      Validate JSON Packer template"
	@echo "  packer-validate-hcl  Validate HCL Packer template"
	@echo ""
	@echo "Other:"
	@echo "  clean                Remove compiled files and artifacts"
