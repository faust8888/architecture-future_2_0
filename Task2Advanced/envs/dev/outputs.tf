output "vm_id" {
  description = "Идентификатор виртуальной машины"
  value       = module.vm.vm_id
}

output "vm_name" {
  description = "Имя виртуальной машины"
  value       = module.vm.vm_name
}

output "vm_internal_ip" {
  description = "Внутренний IP-адрес"
  value       = module.vm.vm_internal_ip
}

output "vm_external_ip" {
  description = "Внешний IP-адрес"
  value       = module.vm.vm_external_ip
}

output "attached_disk_id" {
  description = "Идентификатор подключаемого диска"
  value       = module.vm.attached_disk_id
}
