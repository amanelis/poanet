resource "aws_internet_gateway" "public" {
  vpc_id = "${aws_vpc.vpc.id}"

  tags = {
    Name        = "${var.environment}-igw"
    Environment = "${var.environment}"
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_subnet" "public" {
  count                   = "${var.zones}"
  vpc_id                  = "${aws_vpc.vpc.id}"
  cidr_block              = "${cidrsubnet(aws_vpc.vpc.cidr_block, 8, count.index)}"
  availability_zone       = "${element(data.aws_availability_zones.available.names, count.index)}"
  map_public_ip_on_launch = true

  tags = "${merge(
    local.tags,
    map("Name", "${var.environment}-public-subnet-${count.index}")
  )}"

  lifecycle {
    create_before_destroy = true
  }
}

locals {
  tags = "${map(
    "Environment", "${var.environment}",
    "SubnetType", "public",
    "KubernetesCluster", "${var.environment}",
    "kubernetes.io/role/elb", "",
    "kubernetes.io/cluster/${var.environment}", "owned"
  )}"
}

resource "aws_route_table" "public" {
  count  = "${var.zones}"
  vpc_id = "${aws_vpc.vpc.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.public.id}"
  }

  lifecycle {
    create_before_destroy = true
  }

  tags {
    Name        = "${var.environment}-public-rt-${count.index}"
    Environment = "${var.environment}"
  }
}

resource "aws_route_table_association" "public" {
  count          = "${var.zones}"
  subnet_id      = "${element(aws_subnet.public.*.id, count.index)}"
  route_table_id = "${element(aws_route_table.public.*.id, count.index)}"
}
