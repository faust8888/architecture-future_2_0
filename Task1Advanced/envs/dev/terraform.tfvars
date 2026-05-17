# Окружение разработки — минимальные ресурсы для тестирования и отладки

environment = "dev"
vm_name     = "budushee-dev-vm"

cpu_cores    = 2
memory_gb    = 4
disk_size_gb = 20

disk_type   = "network-hdd"
platform_id = "standard-v3"
zone        = "ru-central1-a"
image_id    = "fd8kdq6d0p8sij7h5qe3" # Ubuntu 22.04 LTS

# Замените на актуальные значения вашего облака
folder_id      = "b1gxxxxxxxxxxxxxxxx"
subnet_id      = "e9bxxxxxxxxxxxxxxxx"
ssh_public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQC... user@dev"
