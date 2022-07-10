terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
    }
  }
  required_version = ">= 0.13"
    backend "s3" {
    endpoint   = "storage.yandexcloud.net"
    bucket     = "net-bucket"
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
  folder_id = "b1gkm9m3so21sp8fb0ml"
  zone      = "ru-central1-a"
}

locals {
  instance_count = {
    stage = 1
    prod = 2
  }
  instance_core = {
    stage = 2
    prod = 4
  }
  instance_memory = {
    stage = 2
    prod = 4
  }
  workspace = {
    stage = "stage"
    prod = "prod"
  }
  virtual_machines = {
    stage = {
      "foreach-0-stage" = { foreach_core = 2, foreach_memory = 2 }
    }
    prod = {
      "foreach-0-prod" = { foreach_core = 4, foreach_memory = 4 }
      "foreach-1-prod" = { foreach_core = 4, foreach_memory = 4 }
    }
  }
}

resource "yandex_compute_instance" "vm-1" {
  count = "${local.instance_count[terraform.workspace]}"
  name = "netology-count-${count.index}-${local.workspace[terraform.workspace]}"
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

resource "yandex_compute_instance" "vm-2" {  
  for_each = local.virtual_machines[terraform.workspace]
  name = each.key
  resources {
    cores  = each.value.foreach_core
    memory = each.value.foreach_memory
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
  name = "network-${local.instance_count[terraform.workspace]}"
}

resource "yandex_vpc_subnet" "subnet-1" {
  name           = "subnet-${local.instance_count[terraform.workspace]}"
  zone           = "ru-central1-a"
  network_id     = yandex_vpc_network.network-1.id
  v4_cidr_blocks = ["192.168.10.0/24"]
}

output "internal_ip_address_vm_1" {
  value = yandex_compute_instance.vm-1.*.network_interface.0.ip_address
}

output "external_ip_address_vm_1" {
  value = yandex_compute_instance.vm-1.*.network_interface.0.nat_ip_address
}

output "internal_ip_address_vm_2" {
  value = values(yandex_compute_instance.vm-2)[*].network_interface.0.ip_address
}

output "external_ip_address_vm_2" {
value = values(yandex_compute_instance.vm-2)[*].network_interface.0.nat_ip_address
}