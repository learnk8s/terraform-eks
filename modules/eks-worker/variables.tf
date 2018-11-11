## General
variable "aws_region" {
  description = "The AWS region to build network infrastructure"
  type        = "string"
}

variable "project" {
  description = "Project name"
  type        = "string"
  default     = "learnk8s"
}

variable "env" {
  description = "Environment of infrastructure"
  type        = "string"
  default     = "dev"
}

variable "extra_tags" {
  description = "Extra AWS tags to be applied to created resources."
  type        = "map"
  default     = {}
}

## Network
variable "subnet_ids" {
  description = "The subnet which hosting worker node"
  type        = "list"
}

## Master
variable "cluster_name" {
  description = "Name of k8s cluster"
  type        = "string"
}

variable "iam_role_name" {
  description = "IAM role name for worker node"
  type        = "string"
}

## Worker
variable "worker_name" {
  description = "Name of worker nodes"
  type        = "string"
  default     = "worker"
}

variable "worker_security_gps" {
  description = "List of security group IDs applied on worker node"
  type        = "list"
}

variable "key_pair_name" {
  description = "SSH key pair for instance access"
  type        = "string"
  default     = ""
}

variable "asg_instance_type" {
  description = "Instance type for worker"
  type        = "string"
  default     = "m5.large"
}

variable "root_volume_type" {
  description = "Volume type on root volume"
  type        = "string"
  default     = "gp2"
}

variable "root_volume_size" {
  description = "Volume size on root volume"
  type        = "string"
  default     = "20"
}

variable "root_volume_iops" {
  description = "Amount of provision IOPS on root volume (For io1 only)"
  type        = "string"
  default     = "10"
}

variable "asg_max_size" {
  description = "Max number of instances on Auto-scaling group"
  type        = "string"
  default     = "5"
}

variable "asg_min_size" {
  description = "Min number of instances on Auto-scaling group"
  type        = "string"
  default     = "1"
}

variable "asg_desired_capacity" {
  description = "Number of instances running on Auto-scaling group"
  type        = "string"
  default     = "1"
}
