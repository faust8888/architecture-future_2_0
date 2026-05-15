variable "folder_id" {
  description = "Идентификатор каталога Yandex Cloud"
  type        = string
}

variable "vm_name" {
  description = "Имя виртуальной машины"
  type        = string
}

variable "cpu_cores" {
  description = "Количество ядер процессора"
  type        = number
}

variable "memory_gb" {
  description = "Объём оперативной памяти в гигабайтах"
  type        = number
}

variable "disk_size_gb" {
  description = "Размер подключаемого диска в гигабайтах"
  type        = number
}

variable "subnet_id" {
  description = "Идентификатор подсети"
  type        = string
}

variable "ssh_public_key" {
  description = "Публичный SSH-ключ"
  type        = string
  sensitive   = true
}

variable "zone" {
  description = "Зона доступности"
  type        = string
}

variable "image_id" {
  description = "Идентификатор образа ОС"
  type        = string
}

variable "platform_id" {
  description = "Платформа виртуализации"
  type        = string
  default     = "standard-v3"
}

variable "disk_type" {
  description = "Тип диска"
  type        = string
  default     = "network-hdd"
}

variable "environment" {
  description = "Имя окружения (dev, stage, prod)"
  type        = string
}
