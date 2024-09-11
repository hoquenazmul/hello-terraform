output "ec2_instance_id" {
  description = "ID of the EC2 instance from the module"
  value       = module.ec2.instance_id
}

output "ec2_instance_public_ip" {
  description = "Public IP of the EC2 instance from the module"
  value       = module.ec2.instance_public_ip
}