// Connecting to AWS service from Packer
packer {
  required_plugins {
    amazon = {
      version = ">= 0.0.1"
      source = "github.com/hashicorp/amazon"
    }
  }
}


// Creating a custom backend server image
source "amazon-ebs" "custom_image" {
//  access_key    = "{{aws_access_key}}"
//  secret_key    = "${var.aws_secret_key}"
  ami_name      = "${var.ami_name}"
  source_ami    = "ami-09e67e426f25ce0d7"
  instance_type = "t2.micro"
  region        = "us-east-1"
  ssh_username = "ubuntu"
}


// Building the entire build sources
build {
  sources = [
    "source.amazon-ebs.custom_image"
  ]
}
