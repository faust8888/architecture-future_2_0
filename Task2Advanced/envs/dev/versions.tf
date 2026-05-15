terraform {
  required_version = ">= 1.6.0"

  required_providers {
    yandex = {
      source  = "yandex-cloud/yandex"
      version = ">= 0.100.0"
    }
  }

  # Удалённое состояние: S3-совместимое хранилище (MinIO / Yandex Object Storage / AWS S3).
  # Параметры передаются через -backend-config=backend.hcl (не хранятся в репозитории).
  backend "s3" {}
}
