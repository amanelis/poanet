resource "aws_security_group" "ethereum" {
  vpc_id      = "${aws_vpc.vpc.id}"
  name        = "${var.environment}-eth-nodes"
  description = "Allow communication to Eth nodes"

  tags {
    Name        = "${var.environment}-ethereum-nodes"
    Environment = "${var.environment}"
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "SSH"
  }

  ingress {
    from_port   = 8000
    to_port     = 8999
    protocol    = "tcp"
    cidr_blocks = ["${var.vpc_cidr}"]
    description = "Ethereum RPC ports"
  }

  ingress {
    from_port   = 30000
    to_port     = 30999
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Ethereum service ports"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Out traffic"
  }
}

################################################################################
# resource "aws_instance" "geth1" {
#   ami           = "ami-0bbe6b35405ecebdb"
#   instance_type = "i3.xlarge"
#
#   key_name               = "${var.key_name}"
#   subnet_id              = "${aws_subnet.public.0.id}"
#   vpc_security_group_ids = ["${aws_security_group.ethereum.id}"]
#   monitoring             = true
#
#   tags {
#     Environment     = "${var.environment}"
#     Name            = "geth.${var.ethereum-geth["geth.full.type"]}.1"
#     NodeID          = "geth.${var.ethereum-geth["geth.mainnet"]}.${var.ethereum-geth["geth.version"]}.${var.ethereum-geth["geth.full.type"]}.1"
#     NodeService     = "${var.ethereum-geth["geth.service"]}"
#     NodeType        = "${var.ethereum-geth["geth.full.type"]}"
#     NodeVersion     = "${var.ethereum-geth["geth.version"]}"
#     NodeNetwork     = "${var.ethereum-geth["geth.mainnet"]}"
#     NodeRanking     = "${var.ethereum-geth["geth.ranking.experimental"]}"
#     AccountID       = "${var.owner_account_id}"
#   }
#
#   lifecycle {
#     create_before_destroy = true
#   }
#
#   provisioner "remote-exec" {
#     connection {
#       user        = "ubuntu"
#       private_key = "${file(var.private_key)}"
#       host        = "${self.public_ip}"
#     }
#
#     inline = [
#       "sudo hostname geth-${var.ethereum-geth["geth.full.type"]}-1",
#       "sudo apt-get install -y software-properties-common",
#       "sudo add-apt-repository -y ppa:ethereum/ethereum",
#       "sudo apt-get update -y",
#       "sudo apt-get install -y build-essential git-core jq ntpdate supervisor vim ethereum",
#       "sudo ntpdate -s time.nist.gov",
#     ]
#   }
# }
#
# resource "aws_route53_record" "geth1" {
#   zone_id = "${data.aws_route53_zone.external.zone_id}"
#   name    = "${aws_instance.geth1.tags.Name}"
#   type    = "A"
#   ttl     = "300"
#   records = ["${aws_instance.geth1.public_ip}"]
# }

################################################################################
# resource "aws_ebs_volume" "from-geth-master-full" {
#   availability_zone = "us-west-2a"
#   snapshot_id       = "${data.aws_ebs_snapshot.geth-master-full.id}"
#   size              = 40
#
#   tags {
#     Name = "geth.master.full.cloned"
#   }
# }
#
# resource "aws_volume_attachment" "geth-master-full" {
#   device_name = "/dev/xvdf"
#   volume_id   = "${aws_ebs_volume.from-geth-master-full.id}"
#   instance_id = "${aws_instance.geth-master-full-attached.id}"
# }
#
# resource "aws_instance" "geth-master-full-attached" {
#   ami           = "${data.aws_ami.ethereum-node.id}"
#   instance_type = "t2.large"
#
#   key_name               = "${var.key_name}"
#   subnet_id              = "${aws_subnet.public.0.id}"
#   vpc_security_group_ids = ["${aws_security_group.ethereum.id}"]
#   monitoring             = true
#
#   tags {
#     Environment     = "${var.environment}"
#     Name            = "geth.${var.ethereum-geth["geth.master.name"]}.${var.ethereum-geth["geth.master.full"]}.cloned"
#     NodeID          = "geth.${var.ethereum-geth["geth.mainnet"]}.${var.ethereum-geth["geth.version"]}.${var.ethereum-geth["geth.master.full"]}"
#     NodeService     = "${var.ethereum-geth["geth.service"]}"
#     NodeType        = "${var.ethereum-geth["geth.master.full"]}"
#     NodeVersion     = "${var.ethereum-geth["geth.version"]}"
#     NodeNetwork     = "${var.ethereum-geth["geth.mainnet"]}"
#     NodeRanking     = "${var.ethereum-geth["geth.ranking.leader"]}"
#     AccountID       = "${var.owner_account_id}"
#   }
#
#   lifecycle {
#     create_before_destroy = true
#   }
#
#   root_block_device {
#     delete_on_termination = true
#     volume_size           = 8
#   }
#
#   volume_tags {
#     Name = "geth.${var.ethereum-geth["geth.master.name"]}.${var.ethereum-geth["geth.master.full"]}.cloned"
#   }
#
#   provisioner "remote-exec" {
#     connection {
#       user        = "${var.ethereum-geth["geth.user"]}"
#       private_key = "${file(var.private_key)}"
#       host        = "${self.public_ip}"
#     }
#
#     inline = [
#       "sudo hostname geth-${var.ethereum-geth["geth.master.name"]}-${var.ethereum-geth["geth.master.full"]}",
#       "sudo ntpdate -s time.nist.gov",
#       "sudo mkdir -p /data",
#       "sudo mkfs -t ext4 /dev/xvdg",
#       "sudo mount /dev/xvdg /data",
#       "sudo chown -R ${var.ethereum-geth["geth.user"]} /data",
#       "sudo systemctl daemon-reload",
#       "sudo systemctl start ${var.ethereum-geth["geth.service"]}.${var.ethereum-geth["geth.master.full"]}",
#     ]
#   }
# }

# ################################################################################
resource "aws_instance" "geth-master-full" {
  ami           = "${data.aws_ami.ethereum-node.id}"
  instance_type = "t2.large"

  key_name               = "${var.key_name}"
  subnet_id              = "${aws_subnet.public.0.id}"
  vpc_security_group_ids = ["${aws_security_group.ethereum.id}"]
  monitoring             = true

  tags {
    Environment = "${var.environment}"
    Name        = "geth.${var.ethereum-geth["geth.master.name"]}.${var.ethereum-geth["geth.master.full"]}"
    NodeID      = "geth.${var.ethereum-geth["geth.mainnet"]}.${var.ethereum-geth["geth.version"]}.${var.ethereum-geth["geth.master.full"]}"
    NodeService = "${var.ethereum-geth["geth.service"]}"
    NodeType    = "${var.ethereum-geth["geth.master.full"]}"
    NodeVersion = "${var.ethereum-geth["geth.version"]}"
    NodeNetwork = "${var.ethereum-geth["geth.mainnet"]}"
    NodeRanking = "${var.ethereum-geth["geth.ranking.leader"]}"
    AccountID   = "${var.owner_account_id}"
  }

  lifecycle {
    create_before_destroy = true
  }

  root_block_device {
    delete_on_termination = true
    volume_size           = 8
  }

  ebs_block_device {
    device_name           = "/dev/sdg"
    delete_on_termination = true

    iops        = "${var.ethereum-geth["geth.full.iops"]}"
    volume_size = "${var.ethereum-geth["geth.full.volume_size"]}"
    volume_type = "io1"
  }

  volume_tags {
    Name = "geth.${var.ethereum-geth["geth.master.name"]}.${var.ethereum-geth["geth.master.full"]}"
  }

  provisioner "remote-exec" {
    connection {
      user        = "${var.ethereum-geth["geth.user"]}"
      private_key = "${file(var.private_key)}"
      host        = "${self.public_ip}"
    }

    inline = [
      "sudo hostname geth-${var.ethereum-geth["geth.master.name"]}-${var.ethereum-geth["geth.master.full"]}",
      "sudo ntpdate -s time.nist.gov",
      "sudo mkdir -p /data",
      "sudo mkfs -t ext4 /dev/xvdg",
      "sudo mount /dev/xvdg /data",
      "sudo chown -R ${var.ethereum-geth["geth.user"]} /data",
      "sudo systemctl daemon-reload",
      "sudo systemctl start ${var.ethereum-geth["geth.service"]}.${var.ethereum-geth["geth.master.full"]}",
    ]
  }
}

resource "aws_route53_record" "geth-master-full" {
  zone_id = "${data.aws_route53_zone.external.zone_id}"
  name    = "${aws_instance.geth-master-full.tags.Name}"
  type    = "A"
  ttl     = "300"
  records = ["${aws_instance.geth-master-full.public_ip}"]
}

################################################################################
resource "aws_instance" "geth-master-fast" {
  ami           = "${data.aws_ami.ethereum-node.id}"
  instance_type = "t2.large"

  key_name               = "${var.key_name}"
  subnet_id              = "${aws_subnet.public.0.id}"
  vpc_security_group_ids = ["${aws_security_group.ethereum.id}"]
  monitoring             = true

  tags {
    Environment = "${var.environment}"
    Name        = "geth.${var.ethereum-geth["geth.master.name"]}.${var.ethereum-geth["geth.master.fast"]}"
    NodeID      = "geth.${var.ethereum-geth["geth.mainnet"]}.${var.ethereum-geth["geth.version"]}.${var.ethereum-geth["geth.master.fast"]}"
    NodeService = "${var.ethereum-geth["geth.service"]}"
    NodeType    = "${var.ethereum-geth["geth.master.fast"]}"
    NodeVersion = "${var.ethereum-geth["geth.version"]}"
    NodeNetwork = "${var.ethereum-geth["geth.mainnet"]}"
    NodeRanking = "${var.ethereum-geth["geth.ranking.leader"]}"
    AccountID   = "${var.owner_account_id}"
  }

  lifecycle {
    create_before_destroy = true
  }

  root_block_device {
    delete_on_termination = true
    volume_size           = 8
  }

  ebs_block_device {
    device_name           = "/dev/sdg"
    delete_on_termination = true

    iops        = "${var.ethereum-geth["geth.fast.iops"]}"
    volume_size = "${var.ethereum-geth["geth.fast.volume_size"]}"
    volume_type = "io1"
  }

  volume_tags {
    Name = "geth.${var.ethereum-geth["geth.master.name"]}.${var.ethereum-geth["geth.master.fast"]}"
  }

  provisioner "remote-exec" {
    connection {
      user        = "${var.ethereum-geth["geth.user"]}"
      private_key = "${file(var.private_key)}"
      host        = "${self.public_ip}"
    }

    inline = [
      "sudo hostname geth-${var.ethereum-geth["geth.master.name"]}-${var.ethereum-geth["geth.master.fast"]}",
      "sudo ntpdate -s time.nist.gov",
      "sudo mkdir -p /data",
      "sudo mkfs -t ext4 /dev/xvdg",
      "sudo mount /dev/xvdg /data",
      "sudo chown -R ${var.ethereum-geth["geth.user"]} /data",
      "sudo systemctl daemon-reload",
      "sudo systemctl start ${var.ethereum-geth["geth.service"]}.${var.ethereum-geth["geth.master.fast"]}",
    ]
  }
}

resource "aws_route53_record" "geth-master-fast" {
  zone_id = "${data.aws_route53_zone.external.zone_id}"
  name    = "${aws_instance.geth-master-fast.tags.Name}"
  type    = "A"
  ttl     = "300"
  records = ["${aws_instance.geth-master-fast.public_ip}"]
}

################################################################################
resource "aws_instance" "geth-master-light" {
  ami           = "${data.aws_ami.ethereum-node.id}"
  instance_type = "t2.large"

  key_name               = "${var.key_name}"
  subnet_id              = "${aws_subnet.public.0.id}"
  vpc_security_group_ids = ["${aws_security_group.ethereum.id}"]
  monitoring             = true

  tags {
    Environment = "${var.environment}"
    Name        = "geth.${var.ethereum-geth["geth.master.name"]}.${var.ethereum-geth["geth.master.light"]}"
    NodeID      = "geth.${var.ethereum-geth["geth.mainnet"]}.${var.ethereum-geth["geth.version"]}.${var.ethereum-geth["geth.master.light"]}"
    NodeService = "${var.ethereum-geth["geth.service"]}"
    NodeType    = "${var.ethereum-geth["geth.master.light"]}"
    NodeVersion = "${var.ethereum-geth["geth.version"]}"
    NodeNetwork = "${var.ethereum-geth["geth.mainnet"]}"
    NodeRanking = "${var.ethereum-geth["geth.ranking.leader"]}"
    AccountID   = "${var.owner_account_id}"
  }

  lifecycle {
    create_before_destroy = true
  }

  root_block_device {
    delete_on_termination = true
    volume_size           = 8
  }

  ebs_block_device {
    device_name           = "/dev/sdg"
    delete_on_termination = true

    iops        = "${var.ethereum-geth["geth.light.iops"]}"
    volume_size = "${var.ethereum-geth["geth.light.volume_size"]}"
    volume_type = "io1"
  }

  volume_tags {
    Name = "geth.${var.ethereum-geth["geth.master.name"]}.${var.ethereum-geth["geth.master.light"]}"
  }

  provisioner "remote-exec" {
    connection {
      user        = "${var.ethereum-geth["geth.user"]}"
      private_key = "${file(var.private_key)}"
      host        = "${self.public_ip}"
    }

    inline = [
      "sudo hostname geth-${var.ethereum-geth["geth.master.name"]}-${var.ethereum-geth["geth.master.light"]}",
      "sudo ntpdate -s time.nist.gov",
      "sudo mkdir -p /data",
      "sudo mkfs -t ext4 /dev/xvdg",
      "sudo mount /dev/xvdg /data",
      "sudo chown -R ${var.ethereum-geth["geth.user"]} /data",
      "sudo systemctl daemon-reload",
      "sudo systemctl start ${var.ethereum-geth["geth.service"]}.${var.ethereum-geth["geth.master.light"]}",
    ]
  }
}

resource "aws_route53_record" "geth-master-light" {
  zone_id = "${data.aws_route53_zone.external.zone_id}"
  name    = "${aws_instance.geth-master-light.tags.Name}"
  type    = "A"
  ttl     = "300"
  records = ["${aws_instance.geth-master-light.public_ip}"]
}
