module "ec2" {
  source        = "github.com/hoquenazmul/hello-terraform/modules/ec2"
  ami           = var.ami
  instance_type = var.instance_type
}
