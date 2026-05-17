variable "vm_name" {
  description = "Имя виртуальной машины"
  type        = string
}

variable "cpu_cores" {
  description = "Количество ядер процессора"
  type        = number

  validation {
    condition     = var.cpu_cores > 0
    error_message = "cpu_cores должно быть больше 0."
  }
}

variable "memory_gb" {
  description = "Объём оперативной памяти в гигабайтах"
  type        = number

  validation {
    condition     = var.memory_gb > 0
    error_message = "memory_gb должно быть больше 0."
  }
}

variable "disk_size_gb" {
  description = "Размер подключаемого диска в гигабайтах"
  type        = number

  validation {
    condition     = var.disk_size_gb > 0
    error_message = "disk_size_gb должно быть больше 0."
  }
}

variable "subnet_id" {
  description = "Идентификатор подсети, в которой размещается ВМ"
  type        = string
}

variable "ssh_public_key" {
  description = "Публичный SSH-ключ для доступа к ВМ"
  type        = string
  sensitive   = true
}

variable "zone" {
  description = "Зона доступности облачного провайдера"
  type        = string
}

variable "image_id" {
  description = "Идентификатор образа операционной системы"
  type        = string
}

variable "platform_id" {
  description = "Платформа виртуализации (тип процессора)"
  type        = string
  default     = "standard-v3"
}

variable "disk_type" {
  description = "Тип подключаемого диска (network-hdd, network-ssd и т.д.)"
  type        = string
  default     = "network-hdd"
}

variable "labels" {
  description = "Метки ресурсов для идентификации и биллинга"
  type        = map(string)
  default     = {}
}

variable "allow_stopping_for_update" {
  description = "Разрешить остановку ВМ при изменении конфигурации"
  type        = bool
  default     = true
}
