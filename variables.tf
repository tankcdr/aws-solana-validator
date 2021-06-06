variable "ami" {
  type        = string
  description = "AMI to be used in EC2, leave empty to use the newest"
  default     = ""
}

variable "enable_ssh" {
  type        = bool
  description = "Open port 22 in the security group"
  default     = false
}

variable "environment" {
  type        = string
  description = "Environment for the deployment"
}

variable "instance_type" {
  type        = string
  description = "Instance type to be used in EC2"
  default     = "m5ad.8xlarge"
}

variable "key_name" {
  type        = string
  description = "SSH Keyname"
  default     = null
}

variable "name" {
  type        = string
  description = "Name (prefix) of to assign to the stack"
  default     = "validator-node"
}

variable "subnet_id" {
  type        = string
  description = "Subnet to deploy the EC2"
}

variable "tags" {
  type        = map(string)
  description = "tags to attach to resources"
  default     = {}
}

variable "volume_size_gb" {
  type        = number
  description = "Size of block device in GB"
  default     = 2048
}

variable "vpc_id" {
  type        = string
  description = "ID of VPC to deploy resources in"
}

variable "whitelist_ips" {
  type        = list(string)
  description = "List of IPs that are whitelisted to the security group"
}
