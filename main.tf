# Module
module "network" {
  source = "./modules/network"

  aws_region = "${var.aws_region}"
  aws_az_number = "${var.aws_az_number}"
  vpc_cidr_block = "${var.vpc_cidr_block}"

  project = "${var.project}"
  env = "${var.env}"
  extra_tags = "${var.extra_tags}"
}

module "eks-master" {
  source = "./modules/eks-master"

  aws_region = "${var.aws_region}"
  vpc_id = "${module.network.vpc_id}"
  vpc_cidr_block = "${module.network.vpc_cidr_block}"
  exist_subnet_ids = "${module.network.vpc_private_subnets}"

  project = "${var.project}"
  env = "${var.env}"
  extra_tags = "${var.extra_tags}"
}

module "eks-worker" {
  source = "./modules/eks-worker"

  aws_region = "${var.aws_region}"

  project = "${var.project}"
  env = "${var.env}"
  extra_tags = "${var.extra_tags}"
}
