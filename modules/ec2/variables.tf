# VPC & Subnet related variables
variable "vpc_name_tag" {
  description = "The Name tag for the VPC"
  type = string
  default = "MyDemoVPC"
}

variable "vpc_cidr" {
  description = "The CIDR range for the VPC"
  type = string
  default = "10.0.0.0/16"
}

variable "subnet_name_tag" {
  description = "The Name tag for the subnet"
  type = string
  default = "MyDemoSubnet"
}

variable "subnet_cidr" {
  description = "The CIDR range for the subnet"
  type = string
  default = "10.0.1.0/24"
}

variable "subnet_ag" {
  description = "The availability zone for the subnet"
  type = string
  default = "us-east-1a"
}

variable "igw_name_tag" {
  description = "the Name tag for the IGW"
  type = string
  default = "MyDemoIGW"
}

variable "route_table_name_tag" {
  description = "The Name tag for the Route Table"
  type = string
  default = "MyDemoRT"
}

# EC2 related variables
variable "ami" { # Required
  description = "The AMI for the EC2 instance"
  type = string
}

variable "instance_type" {
  description = "The instance type for the EC2 instance"
  type = string
  default = "t2.micro"
}

variable "instance_name_tag" {
  description = "The Name tag for the EC2 instance"
  type = string
  default = "MyNewInstance"
}

variable "sg_name_tag" {
  description = "The Name tag for the EC2 SG"
  type = string
  default = "MyDemoSGforEC2"
}

variable "allow_all_ips" {
  description = "The IP range that allows access from all IPs"
  type = string
  default = "0.0.0.0/0"
}

variable "ingress_rules" {
  description = "List of ingress rules"
  type        = list(
    object({
      from_port   = number
      to_port     = number
      protocol    = string
      cidr_blocks = list(string)
    })
  )
  default = [
    {
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    },
    {
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    },
    {
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  ]
}
