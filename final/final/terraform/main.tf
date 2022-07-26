terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
    }
  }
  required_version = ">= 0.13"
  backend "s3" {
    endpoint                    = "storage.yandexcloud.net"
    bucket                      = "final-bucket"
    region                      = "ru-central1"
    key                         = ".terraform/terraform.tfstate"
    skip_region_validation      = true
    skip_credentials_validation = true
  }
}

variable "OAuth" {
  type = string
}

provider "yandex" {
  token     = var.OAuth
  cloud_id  = "b1g68om2q7lso45llau8"
  folder_id = "b1gnfl6q90bn0alfc70i"
  zone      = local.vpc_zone[terraform.workspace]
}

locals {
  instance_count = {
    stage = 1
    prod  = 1
  }
  vpc_zone = {
    stage = "ru-central1-a"
    prod  = "ru-central1-b"
  }
  vpc_v4_cidr_blocks = {
    stage = ["192.168.10.0/24"]
    prod  = ["192.168.20.0/24"]
  }
  workspace = {
    stage = "stage"
    prod  = "prod"
  }
}