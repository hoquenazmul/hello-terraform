# VPC
resource "aws_vpc" "my_vpc" {
  cidr_block = var.vpc_cidr

  tags = {
    Name = var.vpc_name_tag
  }
}

# Subnet
resource "aws_subnet" "my_subnet" {
  vpc_id            = aws_vpc.my_vpc.id
  cidr_block        = var.subnet_cidr
  availability_zone = var.subnet_ag

  tags = {
    Name = var.subnet_name_tag
  }
}

# IGW
resource "aws_internet_gateway" "my_igw" {
  vpc_id = aws_vpc.my_vpc.id

  tags = {
    Name = var.igw_name_tag
  }
}

# Route Table
resource "aws_route_table" "my_rt" {
  vpc_id = aws_vpc.my_vpc.id

  route {
    cidr_block = var.allow_all_ips
    gateway_id = aws_internet_gateway.my_igw.id
  }

  tags = {
    Name = var.route_table_name_tag
  }
}

# Associate Route Table with Subnet
resource "aws_route_table_association" "public_rt_assoc_1" {
  subnet_id      = aws_subnet.my_subnet.id
  route_table_id = aws_route_table.my_rt.id
}

# Security Group for EC2 Instance
resource "aws_security_group" "my_sg_ec2" {
  name        = "allow-web-traffic"
  description = "Allow Web inbound traffic"
  vpc_id      = aws_vpc.my_vpc.id

  dynamic "ingress" {
    for_each = var.ingress_rules
    content {
      from_port = ingress.value.from_port
      to_port = ingress.value.to_port
      protocol = ingress.value.protocol
      cidr_blocks = ingress.value.cidr_blocks
    }
  }

  # ingress {
  #   description = "HTTPS"
  #   from_port   = 443
  #   to_port     = 443
  #   protocol    = "tcp"
  #   cidr_blocks = [var.allow_all_ips]
  # }
  # ingress {
  #   description = "HTTP"
  #   from_port   = 80
  #   to_port     = 80
  #   protocol    = "tcp"
  #   cidr_blocks = [var.allow_all_ips]
  # }
  # ingress {
  #   description = "SSH"
  #   from_port   = 22
  #   to_port     = 22
  #   protocol    = "tcp"
  #   cidr_blocks = [var.allow_all_ips]
  # }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.allow_all_ips]
  }

  tags = {
    Name = var.sg_name_tag
  }
}

# EC2 Instance
resource "aws_instance" "web_server" {
  ami           = var.ami
  instance_type = var.instance_type

  subnet_id                   = aws_subnet.my_subnet.id
  availability_zone           = var.subnet_ag
  associate_public_ip_address = true
  vpc_security_group_ids      = [aws_security_group.my_sg_ec2.id]

  user_data = <<-EOF
  #!/bin/bash
  # install httpd (Linux 2 version)
  yum update -y
  yum install -y httpd
  systemctl start httpd
  systemctl enable httpd
  echo "<h1>Hello World from $(hostname -f)</h1>" > /var/www/html/index.html
  EOF

  tags = {
    Name = var.instance_name_tag
  }
}
