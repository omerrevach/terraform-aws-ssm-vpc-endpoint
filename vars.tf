variable "region" {
  description = "Your AWS Region"
  type = string
}

variable "vpc_id" {
  description = "Your VPC ID"
  type = string
}

variable "private_subnet_ids" {
  description = "List of Private Subnet IDS for vpc endpoint"
  type = list(string)
}

variable "private_subnet_cidr_blocks" {
  description = "CIDR blocks of private subnets for security group rules"
  type = list(string)
}