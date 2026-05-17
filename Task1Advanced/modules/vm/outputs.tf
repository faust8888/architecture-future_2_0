output "vm_id" {
  description = "Идентификатор виртуальной машины"
  value       = yandex_compute_instance.vm.id
}

output "vm_name" {
  description = "Имя виртуальной машины"
  value       = yandex_compute_instance.vm.name
}

output "vm_fqdn" {
  description = "FQDN виртуальной машины"
  value       = yandex_compute_instance.vm.fqdn
}

output "vm_internal_ip" {
  description = "Внутренний IP-адрес виртуальной машины"
  value       = yandex_compute_instance.vm.network_interface[0].ip_address
}

output "vm_external_ip" {
  description = "Внешний IP-адрес виртуальной машины (при включённом NAT)"
  value       = yandex_compute_instance.vm.network_interface[0].nat_ip_address
}

output "attached_disk_id" {
  description = "Идентификатор подключаемого диска"
  value       = yandex_compute_disk.attached.id
}

output "attached_disk_name" {
  description = "Имя подключаемого диска"
  value       = yandex_compute_disk.attached.name
}

output "boot_disk_id" {
  description = "Идентификатор загрузочного диска"
  value       = yandex_compute_instance.vm.boot_disk[0].disk_id
}
