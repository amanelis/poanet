variable "poa_node_count" {
  description = "Number of PoA nodes to start in the chain.. Should do multiples of 3 for 3 availability_zones"
  default     = 3
}

resource "aws_security_group" "ethereum-poa" {
  vpc_id      = "${aws_vpc.vpc.id}"
  name        = "ethereum-poa"
  description = "Default port requirements for Ethereum nodes"

  tags {
    Name = "ethereum-poa"
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "SSH"
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "HTTP"
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "HTTPS"
  }

  ingress {
    from_port   = 8000
    to_port     = 8099
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Ethereum mangement ports"
  }

  ingress {
    from_port = 8100
    to_port   = 8999
    protocol  = "tcp"

    cidr_blocks = [
      "${var.vpc_cidr}",
      "172.250.0.0/16",
      "172.68.0.0/16",
      "76.120.0.0/16",
    ]

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
  }
}

################################################################################
# CONTROLLER
################################################################################
resource "aws_instance" "controller" {
  ami           = "${data.aws_ami.ethereum-poa.id}"
  instance_type = "t2.micro"

  key_name               = "${var.key_name}"
  subnet_id              = "${aws_subnet.public.0.id}"
  vpc_security_group_ids = ["${aws_security_group.ethereum-poa.id}"]
  monitoring             = true

  tags {
    Environment = "${var.environment}"
    Name        = "poa.controller"
    NodeID      = "poa.controller"
    NodeService = "poa"
    NodeType    = "controller"
    NodeVersion = "${var.ethereum-geth["geth.version"]}"
    NodeNetwork = "${var.ethereum-geth["geth.private"]}"
    NodeRanking = "${var.ethereum-geth["geth.private"]}"
    AccountID   = "${var.owner_account_id}"
  }

  lifecycle {
    create_before_destroy = true
  }

  root_block_device {
    delete_on_termination = true
    volume_size           = 12
    volume_type           = "gp2"
  }

  volume_tags {
    Name = "poa.controller"
  }

  provisioner "remote-exec" {
    connection {
      user        = "ubuntu"
      private_key = "${file(var.private_key)}"
      host        = "${self.public_ip}"
    }

    inline = [
      "sudo hostnamectl set-hostname controller",
      "sudo ntpdate -s time.nist.gov",
      "date +%s | sha256sum | base64 | head -c 32 > /home/ubuntu/.passfile",
      "echo 'export ACCOUNT_ID=governance' >> /home/ubuntu/.bashrc",
      "ssh-keygen -f /home/ubuntu/.ssh/id_rsa -t rsa -N ''",
    ]
  }
}

resource "aws_route53_record" "controller" {
  zone_id = "${data.aws_route53_zone.external.zone_id}"
  name    = "controller.poa"
  type    = "A"
  ttl     = "300"
  records = ["${aws_instance.controller.public_ip}"]
}

################################################################################
# NODES
################################################################################
resource "aws_instance" "node" {
  count         = "${var.poa_node_count}"
  ami           = "${data.aws_ami.ethereum-poa.id}"
  instance_type = "t2.medium"

  availability_zone      = "${element(data.aws_availability_zones.available.names, count.index)}"
  key_name               = "${var.key_name}"
  subnet_id              = "${element(aws_subnet.public.*.id, count.index)}"
  vpc_security_group_ids = ["${aws_security_group.ethereum-poa.id}"]
  monitoring             = true

  tags {
    Environment = "${var.environment}"
    Name        = "poa.node.${count.index}"
    NodeID      = "poa.node.${count.index}"
    NodeService = "poa"
    NodeType    = "node"
    NodeVersion = "${var.ethereum-geth["geth.version"]}"
    NodeNetwork = "${var.ethereum-geth["geth.private"]}"
    NodeRanking = "${var.ethereum-geth["geth.private"]}"
    AccountID   = "${var.owner_account_id}"
  }

  lifecycle {
    create_before_destroy = true
  }

  root_block_device {
    delete_on_termination = true
    volume_size           = 12
    volume_type           = "gp2"
  }

  volume_tags {
    Name = "poa.node.${count.index}"
  }

  provisioner "remote-exec" {
    connection {
      user        = "ubuntu"
      private_key = "${file(var.private_key)}"
      host        = "${self.public_ip}"
      timeout     = "60s"
    }

    inline = [
      "sudo hostnamectl set-hostname node${count.index}",
      "sudo ntpdate -s time.nist.gov",
    ]
  }
}

resource "aws_route53_record" "node" {
  count   = "${var.poa_node_count}"
  zone_id = "${data.aws_route53_zone.external.zone_id}"
  name    = "node${count.index}.poa"
  type    = "A"
  ttl     = "300"
  records = ["${element(aws_instance.node.*.public_ip, count.index)}"]
}
