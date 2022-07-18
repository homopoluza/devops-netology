terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
    }
  }
  required_version = ">= 0.13"
    backend "s3" {
    endpoint   = "storage.yandexcloud.net"
    bucket     = "final-bucket"
    region     = "ru-central1"
    key        = ".terraform/terraform.tfstate"
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
    prod = 1
  }
  instance_core = {
    stage = 4
    prod = 4
  }
  instance_memory = {
    stage = 4
    prod = 4
  }
  vpc_zone = {
    stage = "ru-central1-a"
    prod = "ru-central1-b"
  }
  vpc_v4_cidr_blocks = {
    stage = ["192.168.10.0/24"]
    prod = ["192.168.20.0/24"]
  }
  workspace = {
    stage = "stage"
    prod = "prod"
  }
}

resource "yandex_compute_instance" "vm-1" {
  count = "${local.instance_count[terraform.workspace]}"
  name = "final-${count.index}-${local.workspace[terraform.workspace]}"
  resources {
    cores  = local.instance_core[terraform.workspace]
    memory = local.instance_memory[terraform.workspace]
  }

  boot_disk {
    initialize_params {
      image_id = "fd81u2vhv3mc49l1ccbb"
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.subnet-1.id
    nat       = true
  }

  metadata = {
    ssh-keys = "ubuntu:${file("~/.ssh/yc_rsa.pub")}"
  }
}

resource "yandex_vpc_network" "network-1" {
  name = "final-network-${local.workspace[terraform.workspace]}-${local.instance_count[terraform.workspace]}"
}

resource "yandex_vpc_subnet" "subnet-1" {
  name           = "subnet-${local.instance_count[terraform.workspace]}-${local.workspace[terraform.workspace]}"
  zone           = local.vpc_zone[terraform.workspace]
  network_id     = yandex_vpc_network.network-1.id
  v4_cidr_blocks = local.vpc_v4_cidr_blocks[terraform.workspace]
}

output "internal_ip_address_vm_1" {
  value = yandex_compute_instance.vm-1.*.network_interface.0.ip_address
}

output "external_ip_address_vm_1" {
  value = yandex_compute_instance.vm-1.*.network_interface.0.nat_ip_address
}