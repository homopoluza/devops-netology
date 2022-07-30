resource "yandex_compute_instance" "gitlab" {
  name  = "gitlab-${local.workspace[terraform.workspace]}"
  hostname = "gitlab.homopoluza.ru"
  resources {
    cores  = 4
    memory = 4
  }

  boot_disk {
    initialize_params {
      image_id = "fd81u2vhv3mc49l1ccbb"
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.subnet-1.id
    ip_address = "192.168.10.50"
  }

  metadata = {
    ssh-keys = "ubuntu:${file("~/.ssh/id_rsa.pub")}"
  }
}
resource "yandex_compute_instance" "runner" {
  name  = "runner-${local.workspace[terraform.workspace]}"
  hostname = "runner.homopoluza.ru"
  resources {
    cores  = 4
    memory = 4
  }

  boot_disk {
    initialize_params {
      image_id = "fd81u2vhv3mc49l1ccbb"
      size = 10
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.subnet-1.id
    ip_address = "192.168.10.60"
  }

  metadata = {
    ssh-keys = "ubuntu:${file("~/.ssh/id_rsa.pub")}"
  }
}
