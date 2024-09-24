provider "aws" {
  region = "ap-northeast-2"
}

# VPC 생성
resource "aws_vpc" "my_vpc" {
  cidr_block = "10.0.0.0/16"
}

# 서브넷 생성
resource "aws_subnet" "my_subnet" {
  vpc_id     = aws_vpc.my_vpc.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "ap-northeast-2a"  # Specify a valid AZ
}

# 보안 그룹 생성
resource "aws_security_group" "my_sg" {
  name        = "allow_ssh"
  description = "Allow SSH inbound traffic"
  vpc_id      = aws_vpc.my_vpc.id

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
}

# EC2 인스턴스 생성
resource "aws_instance" "ec2" {
  ami                    = "ami-0a5a6128e65676ebb"
  instance_type         = "t2.micro"
  subnet_id             = aws_subnet.my_subnet.id
  vpc_security_group_ids = [aws_security_group.my_sg.id]

  # Public IP address assignment
  associate_public_ip_address = true
}

# EC2 인스턴스 퍼블릭 IP 출력
output "ec2_ip" {
  value = aws_instance.ec2.public_ip
}
