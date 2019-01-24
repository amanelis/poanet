resource "local_file" "values" {
  content  = "${data.template_file.values.rendered}"
  filename = "output/values-${var.environment}.yaml"
}

data "template_file" "values" {
  template = "${file("${path.module}/templates/values.yaml")}"

  vars {
    vpc_id      = "${aws_vpc.vpc.id}"
    environment = "${var.environment}"
  }
}
