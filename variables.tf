variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
}

variable "ami_id" {
  description = "AMI ID for the instances (Amazon Linux 2 or Ubuntu)"
  type        = string
}

variable "instance_type" {
  description = "Instance type for EC2 instances"
  type        = string
}

# This will be populated from .env via TF_VAR_tailscale_auth_key
variable "tailscale_auth_key" {
  description = "Tailscale authentication key for vm-1"
  type        = string
  sensitive   = true
} 