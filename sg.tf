resource "aws_default_security_group" "default" {
vpc_id      = aws_vpc.wordpress-vpc.id
ingress {
    protocol  = -1
    self      = true
    from_port = 0
    to_port   = 0
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "ssh" {
    name = "ssh-sg"
    description = "Bastion Security Group"
    vpc_id      = aws_vpc.wordpress-vpc.id
    ingress {
     from_port   = 22
     to_port     = 22
     protocol    = "tcp"
     cidr_blocks = ["0.0.0.0/0"]
  }

    egress {
     from_port   = 0
     to_port     = 0
     protocol    = "-1"
     cidr_blocks = ["0.0.0.0/0"]
  }

tags = {
  "Name" = "ssh-sg"
}
}

resource "aws_security_group" "web" {
    name = "web-sg"
    description = "Web Security Group"
    vpc_id      = aws_vpc.wordpress-vpc.id
    ingress {
     from_port   = 80
     to_port     = 80
     protocol    = "tcp"
     cidr_blocks = ["0.0.0.0/0"]
  }

    egress {
     from_port   = 0
     to_port     = 0
     protocol    = "-1"
     cidr_blocks = ["0.0.0.0/0"]
  }

tags = {
  "Name" = "web-sg"
}
}

