output "bastion_public_ip" {
  value       = aws_instance.bastion.public_ip
  description = "Public IP of Bastion Host"
}

output "ubuntu_private_ip" {
  value       = aws_instance.ubuntu_redis.private_ip
  description = "Private IP of Ubuntu Redis Server"
}

output "al2023_private_ip" {
  value       = aws_instance.al2023_redis.private_ip
  description = "Private IP of Amazon Linux Redis Server"
}