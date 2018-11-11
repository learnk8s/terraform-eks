data "template_file" "user_data" {
  template = "${file("${path.module}/resources/user_data.sh.tpl")}"

  vars {
    cluster_name = "${var.cluster_name}"
  }
}

resource "aws_launch_configuration" "worker_launch_config" {
  name_prefix   = "${var.cluster_name}-${var.worker_name}-lc-"
  instance_type = "${var.asg_instance_type}"

  image_id             = "${data.aws_ami.eks_worker_ami.id}"
  iam_instance_profile = "${aws_iam_instance_profile.workers.arn}"

  user_data = "${data.template_file.user_data.rendered}"

  key_name        = "${var.key_pair_name}"
  security_groups = ["${var.worker_security_gps}"]

  root_block_device {
    volume_type = "${var.root_volume_type}"
    volume_size = "${var.root_volume_size}"
    iops        = "${var.root_volume_type == "io1" ? var.root_volume_iops : 0 }"
  }

  lifecycle {
    create_before_destroy = true
    ignore_changes        = ["image_id"]
  }
}

resource "aws_autoscaling_group" "asg_gp" {
  name_prefix = "${var.cluster_name}-${var.worker_name}-asg-"

  max_size         = "${var.asg_max_size}"
  min_size         = "${var.asg_min_size}"
  desired_capacity = "${var.asg_desired_capacity}"

  launch_configuration = "${aws_launch_configuration.worker_launch_config.name}"

  vpc_zone_identifier = ["${var.subnet_ids}"]

  tags = ["${list(
    map("key", "Name", "value", "${var.cluster_name}-${var.worker_name}", "propagate_at_launch", true),
    map("key", "NodeGroup", "value", "${var.worker_name}", "propagate_at_launch", true),
    map("key", "Project", "value", "${var.project}", "propagate_at_launch", true),
    map("key", "Env", "value", "${var.env}", "propagate_at_launch", true),
    map("key", "kubernetes.io/cluster/${var.cluster_name}", "value", "owned", "propagate_at_launch", true)
  )}"]
}
