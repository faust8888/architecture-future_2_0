resource "yandex_compute_disk" "attached" {
  name   = "${var.vm_name}-disk"
  type   = var.disk_type
  zone   = var.zone
  size   = var.disk_size_gb
  labels = var.labels
}

resource "yandex_compute_instance" "vm" {
  name        = var.vm_name
  platform_id = var.platform_id
  zone        = var.zone
  labels      = var.labels

  allow_stopping_for_update = var.allow_stopping_for_update

  resources {
    cores  = var.cpu_cores
    memory = var.memory_gb
  }

  boot_disk {
    initialize_params {
      image_id = var.image_id
      size     = var.disk_size_gb
      type     = var.disk_type
    }
  }

  network_interface {
    subnet_id = var.subnet_id
    nat       = true
  }

  metadata = {
    ssh-keys = "ubuntu:${var.ssh_public_key}"
  }

  secondary_disk {
    disk_id = yandex_compute_disk.attached.id
  }
}
