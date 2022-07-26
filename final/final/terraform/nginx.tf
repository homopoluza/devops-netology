resource "yandex_compute_instance" "rev-proxy" {
  name  = "rev-proxy-${local.workspace[terraform.workspace]}"
  hostname = "homopoluza.ru"
  resources {
    cores  = 2
    memory = 2
  }

  boot_disk {
    initialize_params {
      image_id = "fd81u2vhv3mc49l1ccbb"
    }
  }

  provisioner "file" {
    source      = "~/.ssh/id_rsa"
    destination = "/home/ubuntu/.ssh/id_rsa"
  
  connection {
    type     = "ssh"
    user     = "ubuntu"
    host     =  "51.250.90.79"
    private_key = file("~/.ssh/id_rsa")
     }
  }

  provisioner "remote-exec" {
    inline = [
      "chmod 600 /home/ubuntu/.ssh/id_rsa"
    ]

  connection {
    type     = "ssh"
    user     = "ubuntu"
    host     =  "51.250.90.79"
    private_key = file("~/.ssh/id_rsa")
     }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.subnet-1.id
    nat       = true
    nat_ip_address = "51.250.90.79"
    ip_address = "192.168.10.10"
  }

  metadata = {
    ssh-keys = "ubuntu:${file("~/.ssh/id_rsa.pub")}"
  }
}
