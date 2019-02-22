data "aws_availability_zones" "available" {}

data "aws_route53_zone" "external" {
  name = "${var.external_zone}."
}

data "aws_ami" "ethereum-node" {
  most_recent = true

  filter {
    name   = "tag:Name"
    values = ["eth-node"]
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
    name   = "tag:NodeOS"
    values = ["ubuntu-18.04"]
  }
}

data "aws_ami" "ethereum-poa" {
  most_recent = true

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
    values = ["1.8.22-stable"]
  }

  filter {
    name   = "tag:NodeOS"
    values = ["ubuntu-18.04"]
  }
}

# data "aws_ebs_snapshot" "geth-master-full" {
#   most_recent = true
#   owners      = ["self"]
#
#   filter {
#     name   = "volume-size"
#     values = ["${var.ethereum-geth["geth.full.volume_size"]}"]
#   }
#
#   filter {
#     name   = "tag:Name"
#     values = ["geth.master.full"]
#   }
# }

