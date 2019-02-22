variable "ethereum-geth" {
  description = "Configuration details on an Ethereum node, any size"

  default = {
    geth.service = "geth"
    geth.mainnet = "mainnet"
    geth.private = "private"
    geth.version = "1_8_22-stable"

    ### Node Ranks #############################################################
    # Used for experimental nodes that should not be indexed
    geth.ranking.experimental = "experimental"

    # Leaders set the pace and are used to boot "follower" nodes off of
    geth.ranking.leader = "leader"

    # Followers are what are booted for customers, these are customer nodes
    geth.ranking.follower = "follower"

    ### Node Ranks #############################################################

    geth.image             = ""
    geth.user              = "ubuntu"
    geth.light.type        = "light"
    geth.light.iops        = 100
    geth.light.volume_size = 75
    geth.fast.type         = "fast"
    geth.fast.iops         = 300
    geth.fast.volume_size  = 250
    geth.full.type         = "full"
    geth.full.iops         = 600
    geth.full.volume_size  = 1000
    geth.master.name       = "master"
    geth.master.full       = "full"
    geth.master.fast       = "fast"
    geth.master.light      = "light"
  }
}

variable "env_short" {
  description = "The short namespace for the environment"
}

variable "environment" {
  description = "The namespace of the environment"
}

variable "external_zone" {
  description = "Default base zone_id"
}

variable "key_name" {
  description = "AWS pem key for SSH access"
}

variable "owner_account_id" {
  description = "The owning account_id, 55f"
}

variable "private_key" {
  description = "Full path location for $key_name"
}

variable "region" {
  description = "The AWS region to allocate resources"
}

variable "ubuntu_user" {
  description = "An ubuntu user for SSH/unix"
}

variable "vpc_cidr" {
  description = "The CIDR range to use for the VPC"
}

variable "vpn_data" {
  description = "Name the of the volume for VPN data persistance"
}

variable "vpn_domain" {
  description = "Public domain for VPN server"
}

variable "vpn_port" {
  description = "Port for the VPN server"
}

variable "zones" {
  description = "The number of AZs to bring resources up in / this should be between 1 and 3"
  default     = 3
}
