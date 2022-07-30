resource "yandex_compute_instance" "app" {
  name  = "app-${local.workspace[terraform.workspace]}"
  hostname = "app.homopoluza.ru"
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
    ip_address = "192.168.10.40"
  }

  metadata = {
    ssh-keys = "ubuntu:${file("~/.ssh/id_rsa.pub")}"
  }
}