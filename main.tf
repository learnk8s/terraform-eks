# Module
module "network" {
  source = "./modules/network"

  aws_region     = "${var.aws_region}"
  aws_az_number  = "${var.aws_az_number}"
  vpc_cidr_block = "${var.vpc_cidr_block}"

  project    = "${var.project}"
  env        = "${var.env}"
  extra_tags = "${var.extra_tags}"
}

module "eks_master" {
  source = "./modules/eks-master"

  aws_region       = "${var.aws_region}"
  vpc_id           = "${module.network.vpc_id}"
  vpc_cidr_block   = "${module.network.vpc_cidr_block}"
  exist_subnet_ids = "${module.network.vpc_private_subnets}"

  project    = "${var.project}"
  env        = "${var.env}"
  extra_tags = "${var.extra_tags}"
}

module "eks_worker" {
  source = "./modules/eks-worker"

  aws_region = "${var.aws_region}"

  cluster_name        = "${module.eks_master.cluster_name}"
  worker_security_gps = ["${module.eks_master.worker_security_gps}"]
  iam_role_name       = "${module.eks_master.worker_iam_role_name}"
  subnet_ids          = "${module.network.vpc_private_subnets}"

  project    = "${var.project}"
  env        = "${var.env}"
  extra_tags = "${var.extra_tags}"

  key_pair_name = "${var.key_pair_name}"
}
