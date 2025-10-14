resource "aws_vpc" "amber" {
  cidr_block = "172.17.0.0/16"
  tags = {
	Name = "${var.prefix}-amber"
  }
}

resource "aws_vpc" "green" {
  cidr_block = "172.18.0.0/16"
  tags = {
	Name = "${var.prefix}-green"
  }
}


resource "aws_subnet" "amber-lb" {
  vpc_id            = aws_vpc.amber.id
  cidr_block        = "172.17.1.0/24"
  availability_zone = "${var.region}a"
  map_public_ip_on_launch = "true"
  tags = {
	Name = "${var.prefix}-amber-lb"
  }
}

resource "aws_subnet" "amber-vms" {
  vpc_id            = aws_vpc.amber.id
  cidr_block        = "172.17.2.0/24"
  availability_zone = "${var.region}b"
  map_public_ip_on_launch = "true"
  tags = {
	Name = "${var.prefix}-amber-vms"
  }
}

resource "aws_subnet" "green-a" {
  vpc_id            = aws_vpc.green.id
  cidr_block        = "172.18.1.0/24"
  availability_zone = "${var.region}a"
  tags = {
	Name = "${var.prefix}-green-a"
  }
}

resource "aws_subnet" "green-b" {
  vpc_id            = aws_vpc.green.id
  cidr_block        = "172.18.2.0/24"
  availability_zone = "${var.region}b"
  tags = {
	Name = "${var.prefix}-green-b"
  }
}

data "aws_caller_identity" "current" {}

resource "aws_vpc_peering_connection" "amber2green" {
  vpc_id = "${aws_vpc.amber.id}"
  peer_owner_id = "${data.aws_caller_identity.current.account_id}"
  peer_vpc_id = "${aws_vpc.green.id}"
  auto_accept = true
}

resource "aws_route" "green2amber" {
  route_table_id = "${aws_vpc.green.main_route_table_id}"
  destination_cidr_block = "${aws_vpc.amber.cidr_block}"
  vpc_peering_connection_id = "${aws_vpc_peering_connection.amber2green.id}"
}

resource "aws_internet_gateway" "gw" {
  vpc_id            = aws_vpc.amber.id
}

resource "aws_default_route_table" "amber" {
  default_route_table_id = aws_vpc.amber.default_route_table_id

  route {
	cidr_block = "0.0.0.0/0"
	gateway_id = aws_internet_gateway.gw.id
  }
  route {
	cidr_block = "${aws_vpc.green.cidr_block}"
	vpc_peering_connection_id = "${aws_vpc_peering_connection.amber2green.id}"
  }
  tags = {
	Name = "${var.prefix}-amber-internet"
  }
}

resource "aws_key_pair" "common-auth" {
  key_name   = "auth-${var.prefix}"
  public_key = "${var.ssh_public_key}"
}



data "aws_ami" "centos" {
  owners      = ["679593333241"]
  most_recent = true

  filter {
      name   = "name"
      values = ["AlmaLinux OS 8.10*"]
  }

  filter {
      name   = "architecture"
      values = ["x86_64"]
  }

  filter {
      name   = "root-device-type"
      values = ["ebs"]
  }
}



