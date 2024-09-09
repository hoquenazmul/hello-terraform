# Prerequisite:
- Install and Configure AWS CLI
- Install terraform on your local

# Steps to follow
- Once you're done with prereqs, clone this repo: `git clone https://github.com/hoquenazmul/hello-terraform.git`
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
