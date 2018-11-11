resource "aws_vpc" "main" {
  cidr_block = "${var.vpc_cidr_block}"

  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = "${merge(map(
    "Name", "${var.project}-${var.env}-eks",
    "Env", "${var.env}",
    "Project", "${var.project}",
    "kubernetes.io/cluster/${var.project}-${var.env}", "owned",
  ), var.extra_tags)}"
}

data "aws_availability_zones" "azs" {}

locals {
  aws_azs = "${slice(data.aws_availability_zones.azs.names, 0, var.aws_az_number)}"
}
