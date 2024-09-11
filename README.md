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

#### Data Source
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

#### Workspace
A Terraform workspace helps you manage separate environments by isolating their state files, which track the resources defined in your configuration. This means you can keep development and production environments separate, with each workspace handling its own set of resources and configurations.

##### Some Workspace Related Commands
```bash
terraform workspace new dev # to create a new workspace
terraform workspace show # to see the current workspace
terraform workspace select dev # to select a specific workspace
```