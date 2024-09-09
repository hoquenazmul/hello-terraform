variable "vpc_name_tag" {
  description = "Value of Name tag for VPC"
  type = string
  default = "MyDemoVPC"
}

variable "vpc_cidr" {
  description = "Value of CIDR range for VPC"
  type = string
  default = "10.0.0.0/16"
}

variable "subnet_name_tag" {
  description = "Value of Name tag for subnet"
  type = string
  default = "MyDemoSubnet"
}

variable "subnet_cidr" {
  description = "Value of CIDR range for subnet"
  type = string
  default = "10.0.1.0/24"
}

variable "subnet_ag" {
  description = "Value of AG for subnet"
  type = string
  default = "us-east-1a"
}

variable "igw_name_tag" {
  description = "Value of Name tag for IGW"
  type = string
  default = "MyDemoIGW"
}

variable "route_table_name_tag" {
  description = "Value of Name tag for Route Table"
  type = string
  default = "MyDemoRT"
}

variable "instance_ami" {
  description = "Value of AMI for EC2 instance"
  type = string
  default = "ami-0182f373e66f89c85" # Amazon Linux
}

variable "instance_type" {
  description = "Value of EC2 instance type"
  type = string
  default = "t2.micro"
}

variable "instance_name_tag" {
  description = "Value of Name tag for EC2 instance"
  type = string
  default = "MyNewInstance"
}

variable "sg_name_tag" {
  description = "Value of Name tag for EC2 SG"
  type = string
  default = "MyDemoSGforEC2"
}
