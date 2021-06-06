output "instance_id" {
  description = "Instance ID of the created EC2"
  value       = aws_instance.this.id
}

output "public_ip" {
  description = "Instance ID of the created EC2"
  value       = aws_instance.this.public_ip
}
