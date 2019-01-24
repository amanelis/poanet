data "aws_availability_zones" "available" {}

data "aws_route53_zone" "external" {
  name = "${var.external_zone}."
}

data "aws_ami" "ethereum-node-1_8_22_unstable" {
    filter {
      name   = "tag:NodeService"
      values = ["geth"]
    }

    filter {
      name   = "tag:NodeVersion"
      values = ["1.8.22-unstable"]
    }

    most_recent = true
}
