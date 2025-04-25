output "vpc_endpoint_ids" {
  description = "Map of SSM service names to their VPC endpoint IDs"
  value       = { for k, v in aws_vpc_endpoint.ssm_endpoint : k => v.id }
}

output "security_group_id" {
  description = "ID of the security group for SSM endpoints"
  value       = aws_security_group.ssm_https.id
}

output "iam_role_arn" {
  description = "ARN of the IAM role for SSM"
  value       = aws_iam_role.ssm_role.arn
}

output "instance_profile_name" {
  description = "Name of the instance profile for SSM"
  value       = aws_iam_instance_profile.ssm_profile.name
}

output "instance_profile_arn" {
  description = "ARN of the instance profile for SSM"
  value       = aws_iam_instance_profile.ssm_profile.arn
}