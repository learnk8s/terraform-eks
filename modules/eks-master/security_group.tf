## Security groups
resource "aws_security_group" "eks" {
  name_prefix = "${var.project}-${var.env}-master-"
  vpc_id      = "${var.vpc_id}"

  tags = "${merge(map(
    "Name", "${var.project}-${var.env}-eks",
    "kubernetes.io/cluster/${var.project}-${var.env}", "owned",
    "Project", "${var.project}",
    "Env", "${var.env}"
  ), var.extra_tags)}"
}

resource "aws_security_group_rule" "eks_cluster_egress" {
  type              = "egress"
  security_group_id = "${aws_security_group.eks.id}"

  from_port   = 0
  to_port     = 0
  protocol    = "-1"
  cidr_blocks = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "eks_cluster_ingress_https" {
  type              = "ingress"
  security_group_id = "${aws_security_group.eks.id}"

  protocol    = "tcp"
  cidr_blocks = ["${var.vpc_cidr_block}"]
  from_port   = 443
  to_port     = 443
}

resource "aws_security_group" "workers" {
  name_prefix = "${var.project}-${var.env}-worker-"
  description = "Security group for all nodes in the cluster."
  vpc_id      = "${var.vpc_id}"

  tags = "${merge(map(
    "Name", "${var.project}-${var.env}-worker",
    "kubernetes.io/cluster/${var.project}-${var.env}", "owned",
    "Project", "${var.project}",
    "Env", "${var.env}"
  ), var.extra_tags)}"
}

resource "aws_security_group_rule" "workers_egress_internet" {
  description       = "Allow nodes all egress to the Internet."
  protocol          = "-1"
  security_group_id = "${aws_security_group.workers.id}"
  cidr_blocks       = ["0.0.0.0/0"]
  from_port         = 0
  to_port           = 0
  type              = "egress"
}

resource "aws_security_group_rule" "workers_ingress_self" {
  description       = "Allow node to communicate with each other."
  protocol          = "-1"
  security_group_id = "${aws_security_group.workers.id}"
  self              = true
  from_port         = 0
  to_port           = 65535
  type              = "ingress"
}

resource "aws_security_group_rule" "workers_ingress_cluster" {
  description              = "Allow workers Kubelets and pods to receive communication from the cluster control plane."
  protocol                 = "tcp"
  security_group_id        = "${aws_security_group.workers.id}"
  source_security_group_id = "${aws_security_group.eks.id}"
  from_port                = 1025
  to_port                  = 65535
  type                     = "ingress"
}

resource "aws_security_group_rule" "workers_ingress_ssh" {
  description       = "Allow access from ssh."
  protocol          = "tcp"
  security_group_id = "${aws_security_group.workers.id}"
  cidr_blocks       = ["0.0.0.0/0"]
  from_port         = 22
  to_port           = 22
  type              = "ingress"
}
