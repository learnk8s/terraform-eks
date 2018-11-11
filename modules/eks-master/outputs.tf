output "cluster_name" {
  value = "${aws_eks_cluster.eks.id}"
}

output "worker_security_gps" {
  value = "${aws_security_group.workers.id}"
}

output "worker_iam_role_name" {
  value = "${aws_iam_role.workers.name}"
}
