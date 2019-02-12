data "aws_availability_zones" "available" {}

data "aws_route53_zone" "external" {
  name = "${var.external_zone}."
}

data "aws_ami" "ethereum-node-1_8_22-stable-ubuntu" {
  filter {
    name   = "tag:Name"
    values = ["go-ethereum-1.8.22-stable-ubuntu"]
  }

  filter {
    name   = "tag:NodeService"
    values = ["geth"]
  }

  filter {
    name   = "tag:NodeVersion"
    values = ["1.8.22-stable"]
  }

  filter {
    name   = "tag:BaseOS"
    values = ["ubuntu-18.04"]
  }

  most_recent = true
}

data "aws_ami" "ethereum-poa-1_25_2018" {
  filter {
    name   = "tag:Name"
    values = ["eth-poa"]
  }

  filter {
    name   = "tag:NodeService"
    values = ["poa"]
  }

  filter {
    name   = "tag:NodeVersion"
    values = ["1.25.2018"]
  }

  filter {
    name   = "tag:BaseOS"
    values = ["ubuntu-18.04"]
  }

  most_recent = true
}
