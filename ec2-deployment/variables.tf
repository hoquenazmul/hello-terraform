variable "ami" {
  description = "The AMI for the EC2 instance"
  type = string
}

variable "instance_type" {
  description = "The instance type for the EC2 instance"
  type = string
  default = "t2.micro"
}