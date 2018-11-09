resource "aws_vpc" "main" {
    cidr_block = "${var.vpc_cidr_block}"

    enable_dns_hostnames = true
    enable_dns_support   = true

    tags = "${merge(map(
        "Name", "${var.project}-${var.env}-eks",
        "Env", "${var.env}",
        "Project", "${var.project}",
    ), var.extra_tags)}"
}

data "aws_availability_zones" "azs" {}

locals {
    aws_azs = "${slice(data.aws_availability_zones.azs.names, 0, var.aws_az_number)}"
}


## Public Subnets

resource "aws_internet_gateway" "igw" {
    vpc_id = "${aws_vpc.main.id}"

    tags = "${merge(map(
        "Name", "${var.project}-${var.env}-igw",
        "Project", "${var.project}",
        "Env", "${var.env}",
    ), var.extra_tags)}"
}

resource "aws_route_table" "default" {
    vpc_id = "${aws_vpc.main.id}"

    tags = "${merge(map(
        "Name", "${var.project}-${var.env}-public",
        "Project", "${var.project}",
        "Env", "${var.env}",
    ), var.extra_tags)}"
}

resource "aws_main_route_table_association" "main_vpc_routes" {
    vpc_id         = "${aws_vpc.main.id}"
    route_table_id = "${aws_route_table.default.id}"
}

resource "aws_route" "igw_route" {
    destination_cidr_block = "0.0.0.0/0"
    route_table_id         = "${aws_route_table.default.id}"
    gateway_id             = "${aws_internet_gateway.igw.id}"
}

resource "aws_subnet" "public_subnet" {
    count             = "${length(local.aws_azs)}"
    vpc_id            = "${aws_vpc.main.id}"
    cidr_block        = "${cidrsubnet(aws_vpc.main.cidr_block, 4, count.index)}"
    availability_zone = "${local.aws_azs[count.index]}"

    tags = "${merge(map(
        "Name", "${var.project}-${var.env}-public-${local.aws_azs[count.index]}",
        "Env", "${var.env}",
        "Project", "${var.project}",
    ), var.extra_tags)}"
}

resource "aws_eip" "nat_eip" {
    count = "${length(local.aws_azs)}"
    vpc   = true

    # Terraform does not declare an explicit dependency towards the internet gateway.
    # this can cause the internet gateway to be deleted/detached before the EIPs.
    # https://github.com/coreos/tectonic-installer/issues/1017#issuecomment-307780549
    depends_on = ["aws_internet_gateway.igw"]
}

resource "aws_nat_gateway" "nat_gw" {
    count         = "${length(local.aws_azs)}"
    allocation_id = "${aws_eip.nat_eip.*.id[count.index]}"
    subnet_id     = "${aws_subnet.public_subnet.*.id[count.index]}"
}

## Private Subnets

resource "aws_route_table" "private_routes" {
    count  = "${length(local.aws_azs)}"
    vpc_id = "${aws_vpc.main.id}"

    tags = "${merge(map(
        "Name", "${var.project}-${var.env}-private-${local.aws_azs[count.index]}",
        "Project", "${var.project}",
        "Env", "${var.env}",
    ), var.extra_tags)}"
}

resource "aws_route" "to_nat_gw" {
    count                  = "${length(local.aws_azs)}"
    route_table_id         = "${aws_route_table.private_routes.*.id[count.index]}"
    destination_cidr_block = "0.0.0.0/0"
    nat_gateway_id         = "${element(aws_nat_gateway.nat_gw.*.id, count.index)}"
    depends_on             = ["aws_route_table.private_routes"]
}
resource "aws_subnet" "private_subnet" {
    count             = "${length(local.aws_azs)}"
    vpc_id            = "${aws_vpc.main.id}"
    cidr_block        = "${cidrsubnet(aws_vpc.main.cidr_block, 4, count.index + length(local.aws_azs))}"
    availability_zone = "${local.aws_azs[count.index]}"

    tags = "${merge(map(
        "Name", "${var.project}-${var.env}-private-${local.aws_azs[count.index]}",
        "Env", "${var.env}",
        "Project", "${var.project}",
    ), var.extra_tags)}"
}

resource "aws_route_table_association" "private_routing" {
    count          = "${length(local.aws_azs)}"
    route_table_id = "${aws_route_table.private_routes.*.id[count.index]}"
    subnet_id      = "${aws_subnet.private_subnet.*.id[count.index]}"
}
