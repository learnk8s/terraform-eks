output "cluster_name" {
  value = "${aws_eks_cluster.eks.id}"
}

output "cluster_id" {
  value = "${var.project}-${var.env}"
}

output "worker_security_gps" {
  value = "${aws_security_group.workers.id}"
}

output "worker_iam_role_name" {
  value = "${aws_iam_role.workers.name}"
}
