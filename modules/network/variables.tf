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
variable "vpc_cidr_block" {
  description = "CIDR block for VPC"
  type        = "string"
}

variable "exist_subnet_ids" {
  description = "Subnet IDs for EKS master"
  type        = "list"
  default     = []
}

variable "aws_az_number" {
  description = "How many AZs want to be used"
  type        = "string"
  default     = "3"
}

## EKS master
variable "config_output_path" {
  description = "The path to store config, e.g. kubeconfig"
  type        = "string"
  default     = ".terraform"
}
