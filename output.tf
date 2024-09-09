output "instance_id" {
  description = "Instance ID of EC2 instance"
  value       = aws_instance.web_server.id
}

output "instance_public_ip" {
  description = "Public IP address of EC2 instance"
  value       = aws_instance.web_server.public_ip
}
