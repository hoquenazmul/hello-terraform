# Prerequisite:
- Install and Configure AWS CLI
- Install terraform on your local

# Steps to follow
- Once you're done with prereqs, clone this repo: `git clone https://github.com/hoquenazmul/hello-terraform.git`
- Navigate to deployment directory, for example: `cd ec2-deployment`
- Initialize terraform with your targeted provider: `terraform init`
- To apply/implement terraform script, use `terraform apply`
- Once you're done, don't forget to delete infra. Otherwise, you've to pay some unexpected costs. So, use `terraform destroy`

# Table of Contents

1. [Useful Terraform Commands](#useful-terraform-commands)
2. [Example Terraform Code Snippets](#example-terraform-code-snippets)
3. [Terraform Meta Arguments](#terraform-meta-arguments)
    - [depends_on](#depends_on)
    - [count](#count)
    - [for_each](#for_each)
    - [provider](#provider)
    - [lifecycle](#lifecycle)
4. [Data Source](#data-source)
5. [Workspace](#workspace)
6. [Provisioners](#provisioners)
7. [Terraform Cloud](#terraform-cloud)

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

## Example Terraform Code Snippets
#### provider
```hcl
provider "aws" {
  region = "us-east-1"
}
```

#### versions
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

#### resource
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

#### variable
```hcl
variable "instance_type" {
  description = "The instance type for the EC2 instance"
  type = string
  default = "t2.micro"
}
```

#### terraform.tfvars
```hcl
instance_type = "t2.micro"
```

#### output
```hcl
output "instance_public_ip" {
  description = "Public IP address of EC2 instance"
  value       = aws_instance.web_server.public_ip
}
```
**[⬆ back to top](#table-of-contents)**

#### locals
```hcl
# Store values that are used only within the current module and don't change based on user input or external configurations.
locals {
  environment = "production"
  instance_type = "t2.micro"
}

resource "aws_instance" "app_server" {
  ami           = "ami-06b21ccaeff8cd686"
  instance_type = local.instance_type  # Using local value for instance type

  tags = {
    Environment = local.environment  # Using local value for environment
  }
}
```

#### list variable & dynamic block
```hcl
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

resource "aws_security_group" "example" {
  vpc_id = aws_vpc.my_vpc.id

  dynamic "ingress" {
    for_each = var.ingress_rules
    content {
      from_port   = ingress.value.from_port
      to_port     = ingress.value.to_port
      protocol    = ingress.value.protocol
      cidr_blocks = ingress.value.cidr_blocks
    }
  }
}
```
**[⬆ back to top](#table-of-contents)**

## Terraform Meta Arguments
#### depends_on
Terraform usually understands dependencies between resources. However, in cases where dependencies aren't automatically detected, the `depends_on` can specify explicit dependencies. This ensures that one resource is only created after another.
```hcl
resource "aws_s3_bucket" "example" {
  bucket = "example-bucket"
}

resource "aws_instance" "example" {
  ami           = "ami-06b21ccaeff8cd686"
  instance_type = "t2.micro"
  depends_on    = [aws_s3_bucket.example]
}
```
**[⬆ back to top](#table-of-contents)**

#### count
`count` lets you create multiple instances of a resource, making it easy to provision identical resources.
```hcl
resource "aws_instance" "web_server" {
  count = 2
  ami           = "ami-06b21ccaeff8cd686"
  instance_type = "t2.micro"

  tags = {
    Name = "web-server-${count.index}"
  }
}

output "public_ips" {
  # value = aws_instance.web_server[0].public_ip
  # value = [for instance in aws_instance.web_server : instance.public_ip]
  value = aws_instance.web_server[*].public_ip
}
```
**[⬆ back to top](#table-of-contents)**

#### for_each
`for_each` lets you provision multiple instances where each has unique configurations. This is useful for resources that need different settings, like tags or instance types.
```hcl
resource "aws_instance" "web_server" {
  for_each = {
    prod = "ami-06b21ccaeff8cd686"
    dev  = "ami-1234567890abcdefg"
  }

  ami           = each.value
  instance_type = "t2.micro"

  tags = {
    Name = "web-server-${each.key}"
  }
}

output "instance_ips" {
  value = [for instance in aws_instance.web_server : instance.public_ip]
}
```
```hcl
variable "instance_configs" {
  description = "Map of instance configurations"
  type = map(
    object({
      ami           = string
      instance_type = string
      tags          = map(string)
    })
  )
  default = {
    instance1 = {
      ami           = "ami-0123456789abcdef0"
      instance_type = "t2.micro"
      tags = {
        Name = "Instance 1"
        Env  = "Production"
      }
    }
    instance2 = {
      ami           = "ami-0987654321fedcba9"
      instance_type = "t2.small"
      tags = {
        Name = "Instance 2"
        Env  = "Development"
      }
    }
  }
}

resource "aws_instance" "example" {
  for_each = var.instance_configs

  ami           = each.value.ami
  instance_type = each.value.instance_type

  tags = each.value.tags
}
```
**[⬆ back to top](#table-of-contents)**

#### provider
`provider` meta-argument is useful for managing resources across multiple regions or accounts by defining separate provider configurations.
```hcl
provider "aws" {
  region = "us-east-1"
}

provider "aws" {
  alias  = "us_west"
  region = "us-west-2"
}

# Create an S3 bucket in the "us-east-1" region using the default provider
resource "aws_s3_bucket" "east_bucket" {
  bucket   = "east-bucket-example"
}

# Create an S3 bucket in the "us-west-2" region using the specified provider alias
resource "aws_s3_bucket" "west_bucket" {
  provider = aws.us_west
  bucket   = "west-bucket-example"
}
```
**[⬆ back to top](#table-of-contents)**

#### lifecycle
`lifecycle` manages the behavior of resources throughout their lifecycle, providing more control over how resources are created, updated, and deleted. Key options:
- create_before_destroy: Ensures a new resource is created before an existing one is destroyed.
- prevent_destroy: Prevents Terraform from destroying a resource.
- ignore_changes: Ignores changes in specified attributes during updates
Examples:
1. `create_before_destroy`
```hcl
resource "aws_instance" "web_server" {
  ami           = "ami-06b21ccaeff8cd686"
  instance_type = "t2.micro"

  lifecycle {
    create_before_destroy = true
  }
}
```
2. `prevent_destroy`
```hcl
resource "aws_s3_bucket" "important_bucket" {
  bucket = "very-important-bucket"

  lifecycle {
    prevent_destroy = true
  }
}
```
3. `ignore_changes`
```hcl
resource "aws_instance" "web_server" {
  ami           = "ami-06b21ccaeff8cd686"
  instance_type = "t2.micro"

  lifecycle {
    ignore_changes = [ami]
  }
}
```
**[⬆ back to top](#table-of-contents)**

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
```hcl
data "aws_ami" "amzlinux2" {
  most_recent = true
  owners      = ["amazon"]
 
  filter {
    name   = "name"
    values = ["al2023-ami-2023.6*-x86_64"]
  }
}

resource "aws_instance" "web-server" {
  ami = data.aws_ami.amzlinux2.id
  instance_type = "t2.micro"

  tags = {
    Name = "my-instance"
  }
}
```
**[⬆ back to top](#table-of-contents)**

## Workspace
A Terraform workspace helps you manage separate environments by isolating their state files, which track the resources defined in your configuration. This means you can keep development and production environments separate, with each workspace handling its own set of resources and configurations.
```sh
terraform.tfstate.d/
├── dev/
│   └── terraform.tfstate
├── prod/
└── qa/
```
#### Some Workspace Related Commands
```bash
terraform workspace new dev # to create a new workspace
terraform workspace show # to see the current workspace
terraform workspace select dev # to select a specific workspace
terraform workspace delete dev # to delete a workspace
```

## Provisioners
Terraform provisioners allow you to execute scripts or commands on your infrastructure after it has been created or updated. They are useful for tasks such as configuration management or initialization.

Types of Provisioners:
1. File Provisioner => Transfer files between your local machine and a remote server.
2. Local-exec Provisioner => Run commands on the local machine where Terraform is executed
3. Remote-exec Provisioner => Run commands on the remote virtual machine created by Terraform.

#### File Provisioner
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

#### Local-exec Provisioner
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

#### Remote-exec Provisioner
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
**[⬆ back to top](#table-of-contents)**

## Terraform Cloud
Terraform Cloud offers a secure, centralized platform to manage and collaborate on infrastructure deployments. Key benefits include:

#### Remote State Management
- Stores state files remotely, enabling access control and version history.
- Tracks who accesses and modifies the state, enhancing security and collaboration.
- Allows rollback to previous versions, simplifying infrastructure recovery.

#### Centralized Run and Workflow Management
- Manages plan and apply operations centrally, ensuring a single source of truth for deployments.
- Enforces plan approval workflows, adding control and accountability.
- Limits runs to one at a time, avoiding conflicts and maintaining stable environments.

![Terraform cloud image](img/Terraform-Cloud.png)

#### Quick Setup
- Get token from Terraform Cloud dashboard
- Navigate to your user dir. windows => `cd C:\Users\john\AppData\Roaming` | linux => `cd ~`. To find the user's `%APPDATA%`, run this `$env:APPDATA` in powershell
- Create terraform rc file. windows => `terraform.rc` and linux => `.terraformrc`
- Save terraform rc file with token. See the example below
- Define the remote backend inside terraform block. See the example below
- Run `terraform init` to reset the existing backend
```hcl
# ~/.terraformrc
credentials "app.terraform.io" {
  token = "xxxxxx.atlasv1.zzzzzzzzzzzzz"
}
```
```hcl
# remote-state.tf
terraform {
  backend "remote" {
    organization = "example_corp"

    workspaces {
      name = "my-app-prod"
    }
  }
}
```

**[⬆ back to top](#table-of-contents)**