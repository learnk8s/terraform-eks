resource "aws_eks_cluster" "eks" {
  name     = "${var.project}-${var.env}"
  role_arn = "${aws_iam_role.eks.arn}"

  vpc_config {
    subnet_ids         = ["${var.exist_subnet_ids}"]
    security_group_ids = ["${aws_security_group.eks.id}"]
  }

  depends_on = [
    "aws_iam_role_policy_attachment.eks_cluster",
    "aws_iam_role_policy_attachment.eks_service",
  ]
}

data "template_file" "aws_auth_cm" {
  template = "${file("${path.module}/resources/aws-auth-cm.yaml.tpl")}"

  vars {
    worker_iam_role_arn = "${aws_iam_role.workers.arn}"
  }
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
    kubeconfig_rendered  = "${data.template_file.kubeconfig.rendered}"
    aws_auth_cm_rendered = "${data.template_file.aws_auth_cm.rendered}"
  }
}
