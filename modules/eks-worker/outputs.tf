output "worker_ami" {
  value = "${data.aws_ami.eks_worker_ami.image_id}"
}
