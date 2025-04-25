# AWS SSM Endpoints Terraform Module

A Terraform module to create AWS Systems Manager VPC endpoints for secure instance management without internet access.

## Features

- Creates all required VPC endpoints for SSM (ssm, ssmmessages, ec2messages)
- Sets up necessary security group for endpoint access
- Creates IAM role and instance profile for EC2 instances
- Enables managing EC2 instances in private subnets without internet connectivity
- Reduces data transfer costs and improves security by keeping traffic within AWS network

## Usage

### Basic Usage

```hcl
module "ssm_endpoints" {
  source = "omerrevach/ssm-endpoints/aws"
  
  name_prefix               = "prod"
  region                    = "us-west-2"
  vpc_id                    = module.vpc.vpc_id
  subnet_ids                = module.vpc.private_subnets
  allowed_cidr_blocks       = module.vpc.private_subnets_cidr_blocks
  
  tags = {
    Environment = "Production"
    ManagedBy   = "Terraform"
  }
}
```

### Using with EC2 Instances

To connect an EC2 instance to SSM using this module:

```hcl
# First deploy the SSM endpoints module
module "ssm_endpoints" {
  source = "omerrevach/ssm-endpoints/aws"
  
  name_prefix         = "prod"
  region              = "us-west-2"
  vpc_id              = module.vpc.vpc_id
  subnet_ids          = module.vpc.private_subnets
  allowed_cidr_blocks = module.vpc.private_subnets_cidr_blocks
}

# Then create an EC2 instance that uses the SSM profile
resource "aws_instance" "example" {
  ami                    = "ami-0123456789abcdef0" 
  instance_type          = "t3.micro"
  subnet_id              = module.vpc.private_subnets[0]
  vpc_security_group_ids = [aws_security_group.example.id]
  
  # Use the instance profile from the SSM endpoints module
  iam_instance_profile   = module.ssm_endpoints.instance_profile_name
  
  # Make sure IMDSv2 is enabled for better security
  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 1
  }
  
  tags = {
    Name = "example-private-instance"
  }
}
```

### Using with Auto Scaling Groups

```hcl
module "ssm_endpoints" {
  source = "omerrevach/ssm-endpoints/aws"
  
  # module parameters...
}

resource "aws_launch_template" "example" {
  name_prefix   = "example-"
  image_id      = "ami-0123456789abcdef0"
  instance_type = "t3.micro"
  
  # Use the instance profile from the SSM endpoints module
  iam_instance_profile {
    name = module.ssm_endpoints.instance_profile_name
  }
  
  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 1
  }
}

resource "aws_autoscaling_group" "example" {
  desired_capacity    = 2
  max_size            = 5
  min_size            = 1
  vpc_zone_identifier = module.vpc.private_subnets
  
  launch_template {
    id      = aws_launch_template.example.id
    version = "$Latest"
  }
}
```

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.0.0 |
| aws | >= 4.0.0 |

## Providers

| Name | Version |
|------|---------|
| aws | >= 4.0.0 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| vpc_id | ID of the VPC where endpoints will be created | `string` | n/a | yes |
| region | AWS region for the SSM endpoints | `string` | n/a | yes |
| subnet_ids | Subnet IDs where the endpoints will be created | `list(string)` | n/a | yes |
| allowed_cidr_blocks | CIDR blocks allowed to access the SSM endpoints | `list(string)` | n/a | yes |
| name_prefix | Prefix for resource names | `string` | `"ssm"` | no |
| tags | Tags to apply to all resources | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| security_group_id | ID of the security group for SSM endpoints |
| vpc_endpoint_ids | Map of SSM service names to VPC endpoint IDs |
| iam_role_arn | ARN of the IAM role for SSM |
| instance_profile_name | Name of the instance profile for SSM |
| instance_profile_arn | ARN of the instance profile for SSM |

## How it Works

1. **VPC Endpoints**: Creates interface endpoints for `ssm`, `ssmmessages`, and `ec2messages` services
2. **Security Group**: Sets up a security group that allows HTTPS traffic from specified CIDR blocks
3. **IAM Role & Profile**: Creates IAM role with SSM Managed Instance Core policy and an instance profile

## Security Considerations

- This module enforces HTTPS connections to the SSM endpoints
- Restrict allowed_cidr_blocks to only the necessary subnet ranges
- Consider using condition keys in IAM policies for additional security
- Make sure instances have IMDSv2 enabled for better security

## Cost Considerations 

Using VPC endpoints incurs charges per endpoint per AZ. As of 2025:
- Interface endpoints: ~$0.01/hour per endpoint per AZ
- Data processing charges apply for traffic going through the endpoints

These costs are typically lower than data transfer costs for instances in private subnets accessing SSM via NAT gateways or internet gateways.