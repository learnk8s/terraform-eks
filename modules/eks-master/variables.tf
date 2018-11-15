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

## Config store
variable "config_output_path" {
  description = "The path to store config, e.g. kubeconfig"
  type        = "string"
  default     = ".terraform"
}

## Networking
variable "vpc_id" {
  description = "VPC to host EKS"
  type        = "string"
}

variable "vpc_cidr_block" {
  description = "CIDR block of VPC which host EKS"
  type        = "string"
}

variable "exist_subnet_ids" {
  description = "The security group which allow worker connect to master"
  type        = "list"
}
