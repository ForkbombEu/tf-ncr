output "instance_id" {
  description = "ID of EC2 instance"
  value       = aws_instance.ncr_instance.id
}
 
output "instance_public_ip" {
   description = "Public IP of EC2 instance"
   value       = aws_instance.ncr_instance.public_ip
}

output "instance_public_dns" {
   description = "Public DNS of EC2 instance"
   value       = aws_instance.ncr_instance.public_dns
}

output "user_data_content" {
  value = file(var.user_data)
}
