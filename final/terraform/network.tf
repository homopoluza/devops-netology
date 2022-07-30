resource "yandex_vpc_network" "network-1" {
  name = "final-network-${local.workspace[terraform.workspace]}-${local.instance_count[terraform.workspace]}"
}

resource "yandex_vpc_subnet" "subnet-1" {
  name           = "subnet-${local.instance_count[terraform.workspace]}-${local.workspace[terraform.workspace]}"
  zone           = local.vpc_zone[terraform.workspace]
  network_id     = yandex_vpc_network.network-1.id
  v4_cidr_blocks = local.vpc_v4_cidr_blocks[terraform.workspace]
  route_table_id          = yandex_vpc_route_table.nat.id
}

resource "yandex_vpc_route_table" "nat" {
  network_id = "${yandex_vpc_network.network-1.id}"
  
  static_route {
    destination_prefix = "0.0.0.0/0"
    next_hop_address   = "192.168.10.10"
  }
}