provider "aws" {
  region = "us-east-1"
}

resource "aws_security_group" "cd-pipeline" {
  name        = "cd-pipeline"
  description = "Continuous Delivery pipeline"

  # SSH access from anywhere
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Jenkins access from anywhere
  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # SonarQube access from anywhere
  ingress {
    from_port   = 9000
    to_port     = 9000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # nginx HTTPS access from anywhere
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # outbound internet access
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_key_pair" "cd-pipeline_rsa" {
  key_name = "cd-pipeline"
  public_key = "${file("cd-pipeline_rsa.pub")}"
}

resource "aws_instance" "web" {
  instance_type = "t2.medium"
  ami = "ami-f4cc1de2"  # Ubuntu Server 16.04
  security_groups = ["${aws_security_group.cd-pipeline.name}"]
  key_name = "cd-pipeline"

  tags {
    Name = "cd-pipeline"
  }

  connection {
    user = "ubuntu"
    private_key = "${file("cd-pipeline_rsa")}"
  }

  provisioner "file" {
    source      = "../docker"
    destination = "~"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo apt-get install apt-transport-https ca-certificates curl software-properties-common",
      "curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -",
      "sudo add-apt-repository 'deb [arch=amd64] https://download.docker.com/linux/ubuntu xenial stable'",
      "sudo apt-get update",
      "sudo apt-get -y install docker-ce",
      "sudo docker --version",
      "curl -L https://github.com/docker/compose/releases/download/1.16.1/docker-compose-`uname -s`-`uname -m` > docker-compose",
      "sudo mv docker-compose /usr/local/bin/docker-compose",
      "sudo chmod +x /usr/local/bin/docker-compose",
      "cd docker",
      "sudo docker-compose build",
      "sudo docker-compose up -d",
      "sleep 30s",
      "curl --silent  --user 'admin:password' 'http://192.168.99.100:8081/artifactory/ui/onboarding/createDefaultRepos' -X POST -H 'Content-Type: application/json;charset=UTF-8'  -H 'Accept: application/json, text/plain, */*' --data-binary '{\"repoTypeList\": [\"Maven\"],\"fromOnboarding\": false}'"
    ]
  }
}

output "public ip address" {
  value = "${aws_instance.web.public_ip}"
}