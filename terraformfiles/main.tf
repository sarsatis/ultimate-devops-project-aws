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
    apt-get install -y curl

    echo "Installing latest stable version of kubectl..."
    curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
    install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
    rm kubectl

    echo "kubectl version installed:"
    kubectl version --client || true
  EOF

  tags = {
    Name = "Ubuntu22-Kubectl-Only",
    Installed = "kubectl",
    Study = "DevOps",
    Sa = "Terraform",
  }
}

output "instance_ip" {
  value = aws_instance.kubectl_instance.public_ip
}
