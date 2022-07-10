# Домашнее задание к занятию "7.3. Основы и принцип работы Терраформ"

## Задача 1. Создадим бэкэнд в S3 (необязательно, но крайне желательно).

Если в рамках предыдущего задания у вас уже есть аккаунт AWS, то давайте продолжим знакомство со взаимодействием
терраформа и aws. 

1. Создайте s3 бакет, iam роль и пользователя от которого будет работать терраформ. Можно создать отдельного пользователя,
а можно использовать созданного в рамках предыдущего задания, просто добавьте ему необходимы права, как описано 
[здесь](https://www.terraform.io/docs/backends/types/s3.html).
1. Зарегистрируйте бэкэнд в терраформ проекте как описано по ссылке выше. 

```
vagrant@vagrant:~/yc-terr-7.3$ terraform init -backend-config=backend.conf

Initializing the backend...

Initializing provider plugins...
- Reusing previous version of yandex-cloud/yandex from the dependency lock file
- Using previously-installed yandex-cloud/yandex v0.76.0

Terraform has been successfully initialized!
```
```
vagrant@vagrant:~/yc-terr-7.3$ terraform apply

Apply complete! Resources: 3 added, 0 changed, 0 destroyed.
```
![S3](https://github.com/homopoluza/devops-netology/blob/main/7/7.3/Screenshot%202022-07-10%20053118.png)

![S3](https://github.com/homopoluza/devops-netology/blob/main/7/7.3/Screenshot%202022-07-10%20071046.png)

## Задача 2. Инициализируем проект и создаем воркспейсы. 

1. Выполните `terraform init`:
    * если был создан бэкэнд в S3, то терраформ создат файл стейтов в S3 и запись в таблице 
dynamodb.
    * иначе будет создан локальный файл со стейтами.  
1. Создайте два воркспейса `stage` и `prod`.
1. В уже созданный `aws_instance` добавьте зависимость типа инстанса от вокспейса, что бы в разных ворскспейсах 
использовались разные `instance_type`.
1. Добавим `count`. Для `stage` должен создаться один экземпляр `ec2`, а для `prod` два. 
1. Создайте рядом еще один `aws_instance`, но теперь определите их количество при помощи `for_each`, а не `count`.
1. Что бы при изменении типа инстанса не возникло ситуации, когда не будет ни одного инстанса добавьте параметр
жизненного цикла `create_before_destroy = true` в один из рессурсов `aws_instance`.
1. При желании поэкспериментируйте с другими параметрами и рессурсами.

![all works](https://github.com/homopoluza/devops-netology/blob/main/7/7.3/Screenshot%202022-07-10%20234032.png)

В виде результата работы пришлите:
* Вывод команды `terraform workspace list`.

```
vagrant@vagrant:~/yc-terr-7.3$ terraform workspace list
  default
* prod
  stage
  ```

* Вывод команды `terraform plan` для воркспейса `prod`.  

```
vagrant@vagrant:~/yc-terr-7.3$ terraform plan

Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:

  # yandex_compute_instance.vm-1[0] will be created
  + resource "yandex_compute_instance" "vm-1" {
      + created_at                = (known after apply)
      + folder_id                 = (known after apply)
      + fqdn                      = (known after apply)
      + hostname                  = (known after apply)
      + id                        = (known after apply)
      + metadata                  = {
          + "ssh-keys" = <<-EOT
                ubuntu:ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCfOfEFf0mOTm4Ork69ksu8W2zflzUf0eAVN8fujm8Occs7VMJ4YfhQUflrIkS4lbttYfQGFRNe6TTXl/va5idunSND8otn1y24wOIE4aFXviLw4Buw8Aha7V/mLIS84KJv4rhtMuKtQDtx2U23rO/9WoNQ5+QQqx3E65m0dEBwLaxO6se3kNPRcUQzG+Qdy6HdJa87bGGzij2sEtc3Ybi/R0el21K/rGmESNrxBM/TTiDISV3Y4Myqx5YQd+WDPBMXonGT0zXflaG0MC4C/U5rrIXt9Hso57S+GXnwegxMOqx7yO0dL5AkYi58TCcjo+NTVNzh9ePjpDSpWvStD9kt vagrant@vagrant
            EOT
        }
      + name                      = "netology-count-0-prod"
      + network_acceleration_type = "standard"
      + platform_id               = "standard-v1"
      + service_account_id        = (known after apply)
      + status                    = (known after apply)
      + zone                      = (known after apply)

      + boot_disk {
          + auto_delete = true
          + device_name = (known after apply)
          + disk_id     = (known after apply)
          + mode        = (known after apply)

          + initialize_params {
              + block_size  = (known after apply)
              + description = (known after apply)
              + image_id    = "fd81u2vhv3mc49l1ccbb"
              + name        = (known after apply)
              + size        = (known after apply)
              + snapshot_id = (known after apply)
              + type        = "network-hdd"
            }
        }

      + network_interface {
          + index              = (known after apply)
          + ip_address         = (known after apply)
          + ipv4               = true
          + ipv6               = (known after apply)
          + ipv6_address       = (known after apply)
          + mac_address        = (known after apply)
          + nat                = true
          + nat_ip_address     = (known after apply)
          + nat_ip_version     = (known after apply)
          + security_group_ids = (known after apply)
          + subnet_id          = (known after apply)
        }

      + placement_policy {
          + host_affinity_rules = (known after apply)
          + placement_group_id  = (known after apply)
        }

      + resources {
          + core_fraction = 100
          + cores         = 4
          + memory        = 4
        }

      + scheduling_policy {
          + preemptible = (known after apply)
        }
    }

  # yandex_compute_instance.vm-1[1] will be created
  + resource "yandex_compute_instance" "vm-1" {
      + created_at                = (known after apply)
      + folder_id                 = (known after apply)
      + fqdn                      = (known after apply)
      + hostname                  = (known after apply)
      + id                        = (known after apply)
      + metadata                  = {
          + "ssh-keys" = <<-EOT
                ubuntu:ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCfOfEFf0mOTm4Ork69ksu8W2zflzUf0eAVN8fujm8Occs7VMJ4YfhQUflrIkS4lbttYfQGFRNe6TTXl/va5idunSND8otn1y24wOIE4aFXviLw4Buw8Aha7V/mLIS84KJv4rhtMuKtQDtx2U23rO/9WoNQ5+QQqx3E65m0dEBwLaxO6se3kNPRcUQzG+Qdy6HdJa87bGGzij2sEtc3Ybi/R0el21K/rGmESNrxBM/TTiDISV3Y4Myqx5YQd+WDPBMXonGT0zXflaG0MC4C/U5rrIXt9Hso57S+GXnwegxMOqx7yO0dL5AkYi58TCcjo+NTVNzh9ePjpDSpWvStD9kt vagrant@vagrant
            EOT
        }
      + name                      = "netology-count-1-prod"
      + network_acceleration_type = "standard"
      + platform_id               = "standard-v1"
      + service_account_id        = (known after apply)
      + status                    = (known after apply)
      + zone                      = (known after apply)

      + boot_disk {
          + auto_delete = true
          + device_name = (known after apply)
          + disk_id     = (known after apply)
          + mode        = (known after apply)

          + initialize_params {
              + block_size  = (known after apply)
              + description = (known after apply)
              + image_id    = "fd81u2vhv3mc49l1ccbb"
              + name        = (known after apply)
              + size        = (known after apply)
              + snapshot_id = (known after apply)
              + type        = "network-hdd"
            }
        }

      + network_interface {
          + index              = (known after apply)
          + ip_address         = (known after apply)
          + ipv4               = true
          + ipv6               = (known after apply)
          + ipv6_address       = (known after apply)
          + mac_address        = (known after apply)
          + nat                = true
          + nat_ip_address     = (known after apply)
          + nat_ip_version     = (known after apply)
          + security_group_ids = (known after apply)
          + subnet_id          = (known after apply)
        }

      + placement_policy {
          + host_affinity_rules = (known after apply)
          + placement_group_id  = (known after apply)
        }

      + resources {
          + core_fraction = 100
          + cores         = 4
          + memory        = 4
        }

      + scheduling_policy {
          + preemptible = (known after apply)
        }
    }

  # yandex_compute_instance.vm-2["foreach-0-prod"] will be created
  + resource "yandex_compute_instance" "vm-2" {
      + created_at                = (known after apply)
      + folder_id                 = (known after apply)
      + fqdn                      = (known after apply)
      + hostname                  = (known after apply)
      + id                        = (known after apply)
      + metadata                  = {
          + "ssh-keys" = <<-EOT
                ubuntu:ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCfOfEFf0mOTm4Ork69ksu8W2zflzUf0eAVN8fujm8Occs7VMJ4YfhQUflrIkS4lbttYfQGFRNe6TTXl/va5idunSND8otn1y24wOIE4aFXviLw4Buw8Aha7V/mLIS84KJv4rhtMuKtQDtx2U23rO/9WoNQ5+QQqx3E65m0dEBwLaxO6se3kNPRcUQzG+Qdy6HdJa87bGGzij2sEtc3Ybi/R0el21K/rGmESNrxBM/TTiDISV3Y4Myqx5YQd+WDPBMXonGT0zXflaG0MC4C/U5rrIXt9Hso57S+GXnwegxMOqx7yO0dL5AkYi58TCcjo+NTVNzh9ePjpDSpWvStD9kt vagrant@vagrant
            EOT
        }
      + name                      = "foreach-0-prod"
      + network_acceleration_type = "standard"
      + platform_id               = "standard-v1"
      + service_account_id        = (known after apply)
      + status                    = (known after apply)
      + zone                      = (known after apply)

      + boot_disk {
          + auto_delete = true
          + device_name = (known after apply)
          + disk_id     = (known after apply)
          + mode        = (known after apply)

          + initialize_params {
              + block_size  = (known after apply)
              + description = (known after apply)
              + image_id    = "fd81u2vhv3mc49l1ccbb"
              + name        = (known after apply)
              + size        = (known after apply)
              + snapshot_id = (known after apply)
              + type        = "network-hdd"
            }
        }

      + network_interface {
          + index              = (known after apply)
          + ip_address         = (known after apply)
          + ipv4               = true
          + ipv6               = (known after apply)
          + ipv6_address       = (known after apply)
          + mac_address        = (known after apply)
          + nat                = true
          + nat_ip_address     = (known after apply)
          + nat_ip_version     = (known after apply)
          + security_group_ids = (known after apply)
          + subnet_id          = (known after apply)
        }

      + placement_policy {
          + host_affinity_rules = (known after apply)
          + placement_group_id  = (known after apply)
        }

      + resources {
          + core_fraction = 100
          + cores         = 4
          + memory        = 4
        }

      + scheduling_policy {
          + preemptible = (known after apply)
        }
    }

  # yandex_compute_instance.vm-2["foreach-1-prod"] will be created
  + resource "yandex_compute_instance" "vm-2" {
      + created_at                = (known after apply)
      + folder_id                 = (known after apply)
      + fqdn                      = (known after apply)
      + hostname                  = (known after apply)
      + id                        = (known after apply)
      + metadata                  = {
          + "ssh-keys" = <<-EOT
                ubuntu:ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCfOfEFf0mOTm4Ork69ksu8W2zflzUf0eAVN8fujm8Occs7VMJ4YfhQUflrIkS4lbttYfQGFRNe6TTXl/va5idunSND8otn1y24wOIE4aFXviLw4Buw8Aha7V/mLIS84KJv4rhtMuKtQDtx2U23rO/9WoNQ5+QQqx3E65m0dEBwLaxO6se3kNPRcUQzG+Qdy6HdJa87bGGzij2sEtc3Ybi/R0el21K/rGmESNrxBM/TTiDISV3Y4Myqx5YQd+WDPBMXonGT0zXflaG0MC4C/U5rrIXt9Hso57S+GXnwegxMOqx7yO0dL5AkYi58TCcjo+NTVNzh9ePjpDSpWvStD9kt vagrant@vagrant
            EOT
        }
      + name                      = "foreach-1-prod"
      + network_acceleration_type = "standard"
      + platform_id               = "standard-v1"
      + service_account_id        = (known after apply)
      + status                    = (known after apply)
      + zone                      = (known after apply)

      + boot_disk {
          + auto_delete = true
          + device_name = (known after apply)
          + disk_id     = (known after apply)
          + mode        = (known after apply)

          + initialize_params {
              + block_size  = (known after apply)
              + description = (known after apply)
              + image_id    = "fd81u2vhv3mc49l1ccbb"
              + name        = (known after apply)
              + size        = (known after apply)
              + snapshot_id = (known after apply)
              + type        = "network-hdd"
            }
        }

      + network_interface {
          + index              = (known after apply)
          + ip_address         = (known after apply)
          + ipv4               = true
          + ipv6               = (known after apply)
          + ipv6_address       = (known after apply)
          + mac_address        = (known after apply)
          + nat                = true
          + nat_ip_address     = (known after apply)
          + nat_ip_version     = (known after apply)
          + security_group_ids = (known after apply)
          + subnet_id          = (known after apply)
        }

      + placement_policy {
          + host_affinity_rules = (known after apply)
          + placement_group_id  = (known after apply)
        }

      + resources {
          + core_fraction = 100
          + cores         = 4
          + memory        = 4
        }

      + scheduling_policy {
          + preemptible = (known after apply)
        }
    }

  # yandex_vpc_network.network-1 will be created
  + resource "yandex_vpc_network" "network-1" {
      + created_at                = (known after apply)
      + default_security_group_id = (known after apply)
      + folder_id                 = (known after apply)
      + id                        = (known after apply)
      + labels                    = (known after apply)
      + name                      = "network-2"
      + subnet_ids                = (known after apply)
    }

  # yandex_vpc_subnet.subnet-1 will be created
  + resource "yandex_vpc_subnet" "subnet-1" {
      + created_at     = (known after apply)
      + folder_id      = (known after apply)
      + id             = (known after apply)
      + labels         = (known after apply)
      + name           = "subnet-2"
      + network_id     = (known after apply)
      + v4_cidr_blocks = [
          + "192.168.10.0/24",
        ]
      + v6_cidr_blocks = (known after apply)
      + zone           = "ru-central1-a"
    }

Plan: 6 to add, 0 to change, 0 to destroy.

Changes to Outputs:
  + external_ip_address_vm_1 = [
      + (known after apply),
      + (known after apply),
    ]
  + external_ip_address_vm_2 = [
      + (known after apply),
      + (known after apply),
    ]
  + internal_ip_address_vm_1 = [
      + (known after apply),
      + (known after apply),
    ]
  + internal_ip_address_vm_2 = [
      + (known after apply),
      + (known after apply),
    ]
```