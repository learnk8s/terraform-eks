provider "aws" {
  region  = "${var.aws_region}"
  version = "~> 1.43.0"
}

provider "template" {
  version = "~> 1.0"
}
