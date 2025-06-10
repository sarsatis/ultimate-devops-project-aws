terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  backend "s3" {
    bucket         = "demo-terraform-eks-state-s3-bucket-541993"
    key            = "terraform.tfstate"
    region         = "us-west-2"
    dynamodb_table = "terraform-eks-state-locks"
    encrypt        = true
  }
}

provider "aws" {
  region = "us-east-1"
}

resource "aws_instance" "kubectl_instance" {
  ami           = "ami-0731becbf832f281e"   # Ubuntu 22.04 LTS in us-east-1
  instance_type = "t3.xlarge"
  key_name      = "devops-key-pair"         
  security_groups = ["launch-wizard-1"]     

  root_block_device {
    volume_size = 30
    volume_type = "gp2"
  }

  user_data = <<-EOF
    #!/bin/bash
    set -e
    exec > /tmp/kubectl_install.log 2>&1

    echo "Updating packages..."
    apt-get update -y
    apt-get install -y unzip curl ca-certificates gnupg software-properties-common

    echo "Installing latest stable version of kubectl..."
    curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
    install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
    rm kubectl

    echo "kubectl version installed:"
    kubectl version --client || true


    sudo install -m 0755 -d /etc/apt/keyrings
    sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc

    sudo chmod a+r /etc/apt/keyrings/docker.asc

    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
      $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

    sudo apt-get update -y

    echo "Installing Docker..."

    sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

    echo "Docker version installed:"
    docker --version || true
    echo "Installation complete. kubectl and Docker are ready to use."

    sudo usermod -aG docker ubuntu

    wget -O- https://apt.releases.hashicorp.com/gpg | \
    gpg --dearmor | \
    sudo tee /usr/share/keyrings/hashicorp-archive-keyring.gpg > /dev/null

    echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] \
    https://apt.releases.hashicorp.com $(lsb_release -cs) main" | \
    sudo tee /etc/apt/sources.list.d/hashicorp.list

    sudo apt-get update -y

    sudo apt-get install -y terraform

    sudo apt install -y golang-go
    sudo apt install -y openjdk-21-jre-headless

    curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"

    unzip awscliv2.zip
    sudo ./aws/install --bin-dir /usr/local/bin --install-dir /usr/local/aws-cli --update

    
    git clone https://github.com/iam-veeramalla/ultimate-devops-project-demo || echo "Git clone failed."


  EOF

  tags = {
    Name = "devops-instance"
  }
}

output "instance_ip" {
  value = aws_instance.kubectl_instance.public_ip
}
