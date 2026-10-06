variable "aws_region" {
  default     = "ap-south-1"
  description = "AWS Region"
}

variable "key_name" {
  type        = string
  description = "AWS EC2 Key Pair Name for SSH access"
}

variable "instance_type" {
  default     = "t3.micro"
  description = "EC2 Instance Type"
}