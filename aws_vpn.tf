resource "aws_security_group" "vpn" {
  name   = "open-vpn"
  vpc_id = "${aws_vpc.vpc.id}"

  tags {
    Name        = "open-vpn"
    Environment = "${var.environment}"
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = "${var.vpn_port}"
    to_port     = "${var.vpn_port}"
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "vpn" {
  instance_type = "t2.micro"
  ami           = "${data.aws_ami.ethereum-poa.id}"

  key_name  = "${var.key_name}"
  subnet_id = "${aws_subnet.public.0.id}"

  vpc_security_group_ids = ["${aws_security_group.vpn.id}"]

  connection {
    user  = "${var.ubuntu_user}"
    agent = true
  }

  provisioner "remote-exec" {
    inline = [
      "docker volume create --name ${var.vpn_data}",
      "docker run -v ${var.vpn_data}:/etc/openvpn --rm kylemanna/openvpn ovpn_genconfig -u udp://${aws_instance.vpn.public_dns}",
      "yes 'yes' | docker run -v ${var.vpn_data}:/etc/openvpn --rm -i kylemanna/openvpn ovpn_initpki nopass",
      "docker run -v ${var.vpn_data}:/etc/openvpn -d -p ${var.vpn_port}:${var.vpn_port}/udp --cap-add=NET_ADMIN kylemanna/openvpn",
      "docker run -v ${var.vpn_data}:/etc/openvpn --rm -it kylemanna/openvpn easyrsa build-client-full ${var.external_zone} nopass",
      "docker run -v ${var.vpn_data}:/etc/openvpn --rm kylemanna/openvpn ovpn_getclient ${var.external_zone} > ~/${var.external_zone}.ovpn",
    ]
  }

  provisioner "local-exec" {
    command = "ssh-keyscan -T 120 ${aws_instance.vpn.public_ip} >> ~/.ssh/known_hosts"
  }

  provisioner "local-exec" {
    command = "scp ${var.ubuntu_user}@${aws_instance.vpn.public_ip}:~/${var.external_zone}.ovpn ."
  }

  tags {
    Name = "openvpn"
  }
}

resource "aws_route53_record" "vpn" {
  zone_id = "${data.aws_route53_zone.external.zone_id}"
  name    = "vpn"
  type    = "A"
  ttl     = "300"
  records = ["${aws_instance.vpn.public_ip}"]
}
