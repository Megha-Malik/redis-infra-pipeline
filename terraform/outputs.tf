output "ubuntu_public_ip" {
  value = aws_instance.ubuntu_redis.public_ip
}

output "al2023_public_ip" {
  value = aws_instance.al2023_redis.public_ip
}