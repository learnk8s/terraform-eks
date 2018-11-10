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
