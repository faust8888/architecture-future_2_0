module "vm" {
  source = "../../modules/vm"

  vm_name        = var.vm_name
  cpu_cores      = var.cpu_cores
  memory_gb      = var.memory_gb
  disk_size_gb   = var.disk_size_gb
  subnet_id      = var.subnet_id
  ssh_public_key = var.ssh_public_key
  zone           = var.zone
  image_id       = var.image_id
  platform_id    = var.platform_id
  disk_type      = var.disk_type

  labels = {
    environment = var.environment
    project     = "budushee-2-0"
    managed_by  = "terraform"
  }
}
