provider "aws" {
  region = "us-east-2"
}

variable "server_port" {
  description = "The port the server will use for HTTP requests"
  type        = number
  default     = 8080
}

resource "aws_security_group" "terraform_instance_sg" {
  name = "terraform-instance-security-group"

  ingress {
    from_port   = var.server_port
    to_port     = var.server_port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "terraform_instance" {
  ami                    = "ami-0c55b159cbfafe1f0"
  instance_type          = "t2.micro"
  vpc_security_group_ids = [aws_security_group.terraform_instance_sg.id]

  user_data = <<-EOF
              #!/bin/bash
              echo "Hello, World!" >index.html
              nohup busybox httpd -f -p ${var.server_port} &
              EOF

  tags = {
    Name = "terraform-instance"
  }
}

output "public_ip" {
  value       = aws_instance.terraform_instance.public_ip
  description = "The public ip address of the web server"
}
