output "internal_ip_address_rev-proxy" {
  value = yandex_compute_instance.rev-proxy.*.network_interface.0.ip_address
}

output "external_ip_address_rev-proxy" {
  value = yandex_compute_instance.rev-proxy.*.network_interface.0.nat_ip_address
}