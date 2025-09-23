terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

provider "aws" {
  region = "us-west-2"
}

resource "aws_security_group" "app_sg" {
  name        = "app-sg"
  description = "Allow SSH, HTTP, and app traffic"

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "App"
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "app_server" {
  ami           = "ami-03aa99ddf5498ceb9" # Ubuntu 24.04 LTS (adjust region if needed)
  instance_type = "t2.micro"
  key_name      = "konecta-key"           # Upload AWS .pem public key manually
  vpc_security_group_ids = [aws_security_group.app_sg.id]

  tags = {
    Name = "konecta-app"
  }
}

output "public_ip" {
  value = aws_instance.app_server.public_ip
}
