data "aws_ami" "eks_worker_ami" {
    most_recent = true
    # executable_users = ["self"]
    # owners = ["amazon"]

    filter {
        name = "name"
        values = ["amazon-eks-node-*"]
    }

    filter {
        name = "owner-id"
        values = ["602401143452"]
    }
}
