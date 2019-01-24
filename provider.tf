provider "aws" {
  region  = "${var.region}"
  version = "~> 1.30"
}

terraform {
  backend "s3" {
    encrypt = true
  }
}
