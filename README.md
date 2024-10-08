# Prerequisite:
- Install and Configure AWS CLI
- Install terraform on your local

# Steps to follow
- Once you're done with prereqs, clone this repo: `git clone https://github.com/hoquenazmul/hello-terraform.git`
- Navigate to deployment directory, for example: `cd ec2-deployment`
- Initialize terraform with your targeted provider: `terraform init`
- To apply/implement terraform script, use `terraform apply`
- Once you're done, don't forget to delete infra. Otherwise, you've to pay some unexpected costs. So, use `terraform destroy`

# Useful Terraform Commands
|Command                                  |Definition                         
|-----------------------------------------|------------------------------------------------------
|`terraform init`                         | to initize the working dir, pull down providers            
|`terraform apply`                        | to apply changes            
|`terraform apply --auto-approve`         | to apply changes without being prompted to enter 'yes'
|`terraform apply -target <resource>`     | to deploy/apply changes to the specific resource like `aws_instance.web_server`
|`terraform destroy`                      | to destroy/cleanup deployment/infra
|`terraform destroy --auto-approve`       | to destroy/cleanup deployment/infra without being prompted to enter 'yes'
|`terraform destroy -target <resource>`   | to destroy specific resource like `aws_instance.web_server`
|`terraform output`                       | to see output values
|`terraform refresh`                      | to update the state to match remote systems, also see outputs without applying changes again
|`terraform state list`                   | to list out all the resources in terraform state
|`terraform state show <state>`           | to see details about specific resource

## Data Source
A Terraform data source is a way to retrieve info about existing resources without creating new ones.
```hcl
data "aws_vpc" "my_vpc" {
  tags = {
    Name = "my-vpc"
  }
}

output "vpc_id" {
  value = data.aws_vpc.my_vpc.id
}
```

## Workspace
A Terraform workspace helps you manage separate environments by isolating their state files, which track the resources defined in your configuration. This means you can keep development and production environments separate, with each workspace handling its own set of resources and configurations.
```sh
terraform.tfstate.d/
├── dev/
│   └── terraform.tfstate
├── prod/
└── qa/
```
##### Some Workspace Related Commands
```bash
terraform workspace new dev # to create a new workspace
terraform workspace show # to see the current workspace
terraform workspace select dev # to select a specific workspace
terraform workspace delete dev # to delete a workspace
```

## Example Terraform Code Snippets
##### provider
```hcl
provider "aws" {
  region = "us-east-1"
}
```

##### versions
```hcl
terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "5.66.0"
    }
  }
}
```

##### resource
```hcl
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
```

##### variable
```hcl
variable "instance_type" {
  description = "The instance type for the EC2 instance"
  type = string
  default = "t2.micro"
}
```

##### terraform.tfvars
```hcl
instance_type = "t2.micro"
```

##### output
```hcl
output "instance_public_ip" {
  description = "Public IP address of EC2 instance"
  value       = aws_instance.web_server.public_ip
}
```

## Provisioners
Terraform provisioners allow you to execute scripts or commands on your infrastructure after it has been created or updated. They are useful for tasks such as configuration management or initialization.

Types of Provisioners:
1. File Provisioner => Transfer files between your local machine and a remote server.
2. Local-exec Provisioner => Run commands on the local machine where Terraform is executed
3. Remote-exec Provisioner => Run commands on the remote virtual machine created by Terraform.

##### File Provisioner
```hcl
resource "aws_instance" "example" {
  ami           = "ami-12345678"
  instance_type = "t2.micro"

  provisioner "file" {
    source      = "local-file.txt"
    destination = "/tmp/remote-file.txt"

    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = file("~/.ssh/id_rsa")
      host        = self.public_ip
    }
  }
}
```

##### Local-exec Provisioner
```hcl
resource "aws_instance" "example" {
  ami           = "ami-12345678"
  instance_type = "t2.micro"

  provisioner "local-exec" {
    # this cmd will be executed in my local
    command    = "echo 'The server\'s IP address is ${self.private_ip}'"
    on_failure = continue
  }
}
```

##### Remote-exec Provisioner
```hcl
resource "aws_instance" "example" {
  ami           = "ami-12345678"
  instance_type = "t2.micro"

  provisioner "remote-exec" {
    inline = [
      "sudo apt-get update",
      "sudo apt-get install -y nginx"
    ]

    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = file("~/.ssh/id_rsa")
      host        = self.public_ip
    }
  }
}
```