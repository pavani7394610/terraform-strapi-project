resource "tls_private_key" "key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "local_file" "pem_file" {
  content         = tls_private_key.key.private_key_pem
  filename        = "${var.ec2_key_name}.pem"
  file_permission = "0400"
}

resource "aws_key_pair" "generated_key" {
  key_name   = var.ec2_key_name
  public_key = tls_private_key.key.public_key_openssh
}

resource "aws_security_group" "strapi_sg" {
  name        = "strapi-sg"
  description = "Allow SSH and Strapi"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 1337
    to_port     = 1337
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

resource "aws_instance" "strapi_server" {
  ami           = "ami-0c7217cdde317cfec"
  instance_type = var.instance_type
  key_name      = aws_key_pair.generated_key.key_name
  security_groups = [aws_security_group.strapi_sg.name]

  user_data = <<-EOF
    #!/bin/bash
    yum update -y
    yum install -y nodejs git
    npm install -y npm
    npm install -g pm2
    mkdir /strapi
    cd /strapi
    npx create-strapi-app@latest my-project --quickstart
    cd my-project
    pm2 start npm --name strapi -- run develop
    pm2 save
  EOF

  tags = {
    Name = "Strapi-Server"
  }
}
