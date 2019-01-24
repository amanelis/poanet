variable "environment" {
  description = "The namespace of the environment"
}

variable "env_short" {
  description = "The short namespace for the environment"
}

variable "external_zone" {
  description = "Default base zone_id"
}

variable "key_name" {
  description = "AWS pem key for SSH access"
}

variable "private_key" {
  description = "Full path location for $key_name"
}

variable "region" {
  description = "The AWS region to allocate resources in"
}

variable "vpc_cidr" {
  description = "The CIDR range to use for the VPC"
}

variable "zones" {
  description = "The number of AZs to bring resources up in"
  default     = 2
}
