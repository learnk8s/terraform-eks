resource "aws_iam_instance_profile" "workers" {
  name = "${var.cluster_name}-${var.worker_name}"

  # role = "${aws_iam_role.workers.name}"
  role = "${var.iam_role_name}"
}
