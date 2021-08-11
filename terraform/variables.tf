variable "availability_zones" {
  type        = list(string)
  description = "List of availability zones, use AWS CLI to find your"
  default     = ["eu-central-1a", "eu-central-1b"]
}

variable "vpc_id" {
  type        = string
  description = "VPC id to create resources, use AWS CLI to find your"
  default     = "vpc-31d0a558"
}

variable "public_subnets" {
  type        = list(string)
  description = "List of subnets, use AWS CLI to find your"
  default     = ["subnet-3d216c54", "subnet-f501618e"]
}

variable "servers_count" {
  type        = number
  description = "Number of instances desired"
  default     = 1
}

variable "keypair_name" {
  type        = string
  description = "Keypar to use for accessing the instance"
}