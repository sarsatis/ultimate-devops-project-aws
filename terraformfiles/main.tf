provider "aws" {
  region = "us-east-1"  # Change this to your desired AWS region
}

resource "aws_instance" "devops_instance" {
  ami           = "ami-0731becbf832f281e"  # Ubuntu AMI ID (you can use this or find the latest one)
  instance_type = "t3.xlarge"  # Change to your desired instance type
  key_name      = "devops-key-pair"  # Your existing key pair
  security_groups = ["launch-wizard-1"]  # Existing security group name

  root_block_device {
    volume_size = 30  # 30GB root volume
    volume_type = "gp2"
  }

  user_data = <<-EOF
    #!/bin/bash
    set -e  # Exit on error
    exec > /tmp/user_data.log 2>&1  # Redirect output and errors to /tmp/user_data.log

    echo "Updating apt packages..."
    sudo apt-get update

    echo "Installing required dependencies..."
    sudo apt-get install -y ca-certificates curl

    echo "Setting up Docker repository..."
    sudo install -m 0755 -d /etc/apt/keyrings
    sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
    sudo chmod a+r /etc/apt/keyrings/docker.asc

    echo "Adding Docker repository..."
    echo "deb [arch=\$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \$(. /etc/os-release && echo \$${UBUNTU_CODENAME:-\$VERSION_CODENAME}) stable" | \
    sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    sudo apt-get update

    echo "Installing Docker..."
    sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

    echo "Adding user to Docker group..."
    sudo usermod -aG docker ubuntu
    

    echo "Installing kubectl..."
    curl -LO "https://dl.k8s.io/release/\$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
    sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl

    echo "Installing dependencies for Terraform..."
    sudo apt-get update && sudo apt-get install -y gnupg software-properties-common

    echo "Adding HashiCorp repository..."
    wget -O- https://apt.releases.hashicorp.com/gpg | \
    gpg --dearmor | \
    sudo tee /usr/share/keyrings/hashicorp-archive-keyring.gpg > /dev/null

    echo "Adding HashiCorp repository to sources list..."
    echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com \$(lsb_release -cs) main" | \
    sudo tee /etc/apt/sources.list.d/hashicorp.list

    echo "Updating apt..."
    sudo apt update

    echo "Installing Terraform..."
    sudo apt-get install -y terraform

    echo "Installing Golang..."
    sudo apt install -y golang-go
  EOF

  tags = {
    Name = "DevOps-EC2-Instance"
  }
}

output "instance_ip" {
  value = aws_instance.devops_instance.public_ip
}
