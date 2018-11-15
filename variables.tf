## General
variable "aws_region" {
  description = "The AWS region to build network infrastructure"
  type        = "string"
  default     = "eu-west-1"
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

## Netorking
variable "aws_az_number" {
  description = "How many AZs want to be used"
  type        = "string"
  default     = "3"
}

variable "vpc_cidr_block" {
  description = "CIDR block for VPC"
  type        = "string"
  default     = "10.0.0.0/16"
}

## EKS master
variable "config_output_path" {
  description = "The path to store config, e.g. kubeconfig"
  type        = "string"
  default     = ".terraform"
}

## EKS worker
variable "key_pair_name" {
  description = "SSH key pair for instance access"
  type        = "string"
}
