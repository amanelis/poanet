resource "aws_security_group" "ethereum" {
  vpc_id      = "${aws_vpc.vpc.id}"
  name        = "${var.environment}-eth-nodes"
  description = "Allow communication to Eth nodes"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 30301
    to_port     = 30301
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 30301
    to_port     = 30301
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 30303
    to_port     = 30303
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 30303
    to_port     = 30303
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Name        = "${var.environment}-ethereum-nodes"
    Environment = "${var.environment}"
  }
}

################################################################################
resource "aws_instance" "geth1" {
  ami           = "ami-0bbe6b35405ecebdb"
  instance_type = "i3.xlarge"

  key_name               = "${var.key_name}"
  subnet_id              = "${aws_subnet.public.0.id}"
  vpc_security_group_ids = ["${aws_security_group.ethereum.id}"]
  monitoring             = true

  tags {
    Environment     = "${var.environment}"
    Name            = "geth1"
    NodeService     = "geth"
    NodeType        = "full"
    NodeVersion     = "1.8.22-unstable"
    NodeNetwork     = "mainnet"
    NodeDescription = "geth.full.mainnet"
  }

  lifecycle {
    create_before_destroy = true
  }

  provisioner "remote-exec" {
    connection {
      user        = "ubuntu"
      private_key = "${file(var.private_key)}"
      host        = "${self.public_ip}"
    }

    inline = [
      "sudo apt-get install -y software-properties-common",
      "sudo add-apt-repository -y ppa:ethereum/ethereum",
      "sudo apt-get update -y",
      "sudo apt-get install -y build-essential git-core jq ntpdate supervisor vim ethereum",
      "sudo ntpdate -s time.nist.gov"
    ]
  }
}

resource "aws_route53_record" "geth1" {
  zone_id = "${data.aws_route53_zone.external.zone_id}"
  name    = "geth1"
  type    = "A"
  ttl     = "300"
  records = ["${aws_instance.geth1.public_ip}"]
}

################################################################################
resource "aws_instance" "geth2" {
  ami           = "${data.aws_ami.ethereum-node-1_8_22_unstable.id}"
  instance_type = "t2.medium"

  key_name               = "${var.key_name}"
  subnet_id              = "${aws_subnet.public.0.id}"
  vpc_security_group_ids = ["${aws_security_group.ethereum.id}"]
  monitoring             = true

  tags {
    Environment     = "${var.environment}"
    Name            = "geth2"
    NodeService     = "geth"
    NodeType        = "light"
    NodeVersion     = "1.8.22-unstable"
    NodeNetwork     = "mainnet"
    NodeDescription = "geth.light.mainnet"
  }

  lifecycle {
    create_before_destroy = true
  }

  provisioner "remote-exec" {
    connection {
      user        = "ubuntu"
      private_key = "${file(var.private_key)}"
      host        = "${self.public_ip}"
    }

    inline = [
      "sudo hostname geth2",
      "sudo ntpdate -s time.nist.gov",
      "sudo systemctl daemon-reload",
      "sudo systemctl start geth.light" # journalctl -f -u geth.light
    ]
  }
}

resource "aws_route53_record" "geth2" {
  zone_id = "${data.aws_route53_zone.external.zone_id}"
  name    = "geth2"
  type    = "A"
  ttl     = "300"
  records = ["${aws_instance.geth2.public_ip}"]
}

# resource "aws_ebs_volume" "geth2" {
#   availability_zone = "us-west-2a"
#   size              = 64
#   iops              = 500
#   type              = "gp2"
#
#   tags = {
#     Name = "geth2"
#   }
# }
#
# resource "aws_volume_attachment" "geth2" {
#   device_name = "/dev/sdz"
#   volume_id   = "${aws_ebs_volume.geth2.id}"
#   instance_id = "${aws_instance.geth2.id}"
# }

################################################################################
resource "aws_instance" "geth3" {
  ami           = "${data.aws_ami.ethereum-node-1_8_22_unstable.id}"
  instance_type = "t2.medium"

  key_name               = "${var.key_name}"
  subnet_id              = "${aws_subnet.public.0.id}"
  vpc_security_group_ids = ["${aws_security_group.ethereum.id}"]
  monitoring             = true

  root_block_device {
    delete_on_termination = true
    iops                  = 500
    volume_size           = 64
    volume_type           = "gp2"
  }

  tags {
    Environment     = "${var.environment}"
    Name            = "geth3"
    NodeService     = "geth"
    NodeType        = "light"
    NodeVersion     = "1.8.22-unstable"
    NodeNetwork     = "mainnet"
    NodeDescription = "geth.light.mainnet"
  }

  lifecycle {
    create_before_destroy = true
  }

  provisioner "remote-exec" {
    connection {
      user        = "ubuntu"
      private_key = "${file(var.private_key)}"
      host        = "${self.public_ip}"
    }

    inline = [
      "sudo hostname geth3",
      "sudo ntpdate -s time.nist.gov",
      "sudo systemctl daemon-reload",
      "sudo systemctl start geth.light" # journalctl -f -u geth.light
    ]
  }
}

resource "aws_route53_record" "geth3" {
  zone_id = "${data.aws_route53_zone.external.zone_id}"
  name    = "geth3"
  type    = "A"
  ttl     = "300"
  records = ["${aws_instance.geth3.public_ip}"]
}

################################################################################
resource "aws_instance" "geth4" {
  ami           = "${data.aws_ami.ethereum-node-1_8_22_unstable.id}"
  instance_type = "t2.medium"

  key_name               = "${var.key_name}"
  subnet_id              = "${aws_subnet.public.0.id}"
  vpc_security_group_ids = ["${aws_security_group.ethereum.id}"]
  monitoring             = true

  root_block_device {
    delete_on_termination = true
    iops                  = 500
    volume_size           = 256
    volume_type           = "gp2"
  }

  tags {
    Environment     = "${var.environment}"
    Name            = "geth4"
    NodeService     = "geth"
    NodeType        = "fast"
    NodeVersion     = "1.8.22-unstable"
    NodeNetwork     = "mainnet"
    NodeDescription = "geth.fast.mainnet"
  }

  lifecycle {
    create_before_destroy = true
  }

  provisioner "remote-exec" {
    connection {
      user        = "ubuntu"
      private_key = "${file(var.private_key)}"
      host        = "${self.public_ip}"
    }

    inline = [
      "sudo hostname geth4",
      "sudo ntpdate -s time.nist.gov",
      "sudo systemctl daemon-reload",
      "sudo systemctl start geth.fast" # journalctl -f -u geth.light
    ]
  }
}

resource "aws_route53_record" "geth4" {
  zone_id = "${data.aws_route53_zone.external.zone_id}"
  name    = "geth4"
  type    = "A"
  ttl     = "300"
  records = ["${aws_instance.geth4.public_ip}"]
}
