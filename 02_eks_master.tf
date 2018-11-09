resource "aws_eks_cluster" "eks" {
  name     = "${var.project}-${var.env}"
  role_arn = "${aws_iam_role.eks.arn}"

  vpc_config {
    # subnet_ids = ["${var.exist_subnet_ids}"]
    subnet_ids = ["${aws_subnet.private_subnet.*.id}"]
    security_group_ids = ["${aws_security_group.eks.id}"]
  }

  depends_on = [
    "aws_iam_role_policy_attachment.eks_cluster",
    "aws_iam_role_policy_attachment.eks_service",
  ]
}


data "template_file" "aws_auth_cm" {
  template = "${file("${path.module}/resources/aws-auth-cm.yaml.tpl")}"
}

resource "local_file" "aws_auth_cm" {
  content  = "${data.template_file.aws_auth_cm.rendered}"
  filename = "${var.config_output_path}/aws-auth-cm.yaml"
}

resource "null_resource" "aws_auth_cm" {
  provisioner "local-exec" {
    command = "kubectl apply -f ${var.config_output_path}/aws-auth-cm.yaml --kubeconfig ${var.config_output_path}/kubeconfig"
  }

  triggers {
    kubeconfig_rendered = "${data.template_file.kubeconfig.rendered}"
  }
}

# Role for EKS Cluster
data "aws_iam_policy_document" "cluster_assume_role_policy" {
  statement {
    sid = "EKSClusterAssumeRole"

    actions = [
      "sts:AssumeRole",
    ]

    principals {
      type        = "Service"
      identifiers = ["eks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "eks" {
  name_prefix        = "${var.project}-${var.env}-master-"
  assume_role_policy = "${data.aws_iam_policy_document.cluster_assume_role_policy.json}"
}

resource "aws_iam_role_policy_attachment" "eks_cluster" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = "${aws_iam_role.eks.name}"
}

resource "aws_iam_role_policy_attachment" "eks_service" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSServicePolicy"
  role       = "${aws_iam_role.eks.name}"
}



## Security groups
resource "aws_security_group" "eks" {
    name_prefix = "${var.project}-${var.env}-master-"
    vpc_id      = "${aws_vpc.main.id}"

    tags = "${merge(map(
        "Name", "${var.project}-${var.env}-eks",
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
    cidr_blocks = ["${aws_vpc.main.cidr_block}"]
    from_port   = 443
    to_port     = 443
}


resource "aws_security_group" "workers" {
  name_prefix = "${var.project}-${var.env}-worker-"
  description = "Security group for all nodes in the cluster."
  vpc_id      = "${aws_vpc.main.id}"

  tags = "${merge(map(
      "Name", "${var.project}-${var.env}-worker",
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
    description              = "Allow node to communicate with each other."
    protocol                 = "-1"
    security_group_id        = "${aws_security_group.workers.id}"
    self                     = true
    from_port                = 0
    to_port                  = 65535
    type                     = "ingress"
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
    description              = "Allow access from ssh."
    protocol                 = "tcp"
    security_group_id        = "${aws_security_group.workers.id}"
    cidr_blocks              = ["0.0.0.0/0"]
    from_port                = 22
    to_port                  = 22
    type                     = "ingress"
}

resource "aws_security_group_rule" "worker_ingress_lb" {
    count = "${length(var.lb_sg_ids)}"

    type                     = "ingress"
    security_group_id        = "${aws_security_group.workers.id}"
    source_security_group_id = "${var.lb_sg_ids[count.index]}"

    protocol  = "tcp"
    from_port = 30000
    to_port   = 32767
}


## S3 config
resource "aws_s3_bucket" "learnk8s" {
  # Buckets must start with a lower case name and are limited to 63 characters,
  # so we prepend the letter 'a' and use the md5 hex digest for the case of a long domain
  # leaving 29 chars for the cluster name.
  bucket = "${ format("%s%s-%s", "a", aws_eks_cluster.eks.id, md5(format("%s-%s", var.aws_region , aws_eks_cluster.eks.endpoint))) }"


  acl = "private"

  tags = "${merge(map(
      "Name", "${aws_eks_cluster.eks.id}-learnk8s",
      "KubernetesCluster", "${aws_eks_cluster.eks.id}",
      "Env", "${var.env}",
      "Project", "${var.project}"
    ), var.extra_tags)}"

}

# kubeconfig
data "template_file" "kubeconfig" {
  template = "${file("${path.module}/resources/kubeconfig")}"

  vars {
    cluster_name          = "${aws_eks_cluster.eks.id}"
    cluster_endpoint      = "${aws_eks_cluster.eks.endpoint}"
    certificate_authority_data = "${aws_eks_cluster.eks.certificate_authority.0.data}"
  }
}

resource "aws_s3_bucket_object" "kubeconfig" {
    bucket  = "${aws_s3_bucket.learnk8s.bucket}"
    key     = "kubeconfig"
    content = "${data.template_file.kubeconfig.rendered}"
    acl     = "private"

    # The current Vishwakarma installer stores bits of the kubeconfig in KMS. As we
    # do not support KMS yet, we at least offload it to S3 for now. Eventually,
    # we should consider using KMS-based client-side encryption, or uploading it
    # to KMS.
    server_side_encryption = "AES256"
    content_type = "text/plain"

    tags = "${merge(map(
        "Name", "${aws_eks_cluster.eks.id}-kubeconfig",
        "KubernetesCluster", "${aws_eks_cluster.eks.id}",
        "Env", "${var.env}",
        "Project", "${var.project}"
    ), var.extra_tags)}"
}

resource "local_file" "kubeconfig" {
    content  = "${data.template_file.kubeconfig.rendered}"
    filename = "${var.config_output_path}/kubeconfig"
}
