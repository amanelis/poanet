resource "aws_eip" "nat" {
  count = "${var.zones}"
  vpc   = true

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_nat_gateway" "nat" {
  count         = "${var.zones}"
  allocation_id = "${element(aws_eip.nat.*.id, count.index)}"
  subnet_id     = "${element(aws_subnet.public.*.id, count.index)}"

  tags {
    Name        = "${var.environment}-nat-${count.index}"
    Environment = "${var.environment}"
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_subnet" "private" {
  count  = "${var.zones}"
  vpc_id = "${aws_vpc.vpc.id}"

  availability_zone = "${element(data.aws_availability_zones.available.names, count.index)}"
  cidr_block        = "${cidrsubnet(aws_vpc.vpc.cidr_block, 8, count.index + 10)}"

  tags {
    Name              = "${var.environment}-private-subnet-${count.index}"
    Environment       = "${var.environment}"
    SubnetType        = "private"
    KubernetesCluster = "${var.environment}"
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_route_table" "nat" {
  count  = "${var.zones}"
  vpc_id = "${aws_vpc.vpc.id}"

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = "${element(aws_nat_gateway.nat.*.id, count.index)}"
  }

  tags {
    Name        = "${var.environment}-nat"
    Environment = "${var.environment}"
    Service     = "nat"
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_route_table_association" "private" {
  count          = "${var.zones}"
  subnet_id      = "${element(aws_subnet.private.*.id, count.index)}"
  route_table_id = "${element(aws_route_table.nat.*.id, count.index)}"

  lifecycle {
    create_before_destroy = true
  }
}
