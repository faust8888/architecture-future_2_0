# Задание 1. Модульная инфраструктура для нескольких сред

Универсальный Terraform-модуль для развёртывания виртуальных машин в Yandex Cloud с поддержкой трёх окружений: **dev**, **stage**, **prod**.

## Структура проекта

```
Task1Advanced/
├── modules/
│   └── vm/
│       ├── main.tf       # ВМ, подключаемый диск, сеть
│       ├── variables.tf  # Входные параметры модуля
│       └── outputs.tf    # Выходные значения
└── envs/
    ├── dev/
    ├── stage/
    └── prod/
```

Каждое окружение содержит:

- `main.tf` — вызов модуля `vm`
- `variables.tf` — переменные окружения
- `terraform.tfvars` — значения параметров для конкретной среды
- `providers.tf`, `versions.tf`, `outputs.tf`

## Модуль `vm`

Модуль создаёт виртуальную машину с загрузочным и дополнительным диском, подключает ВМ к указанной подсети и настраивает SSH-доступ.

### Входные параметры

| Параметр | Тип | Обязательный | Описание |
|----------|-----|--------------|----------|
| `vm_name` | `string` | да | Имя виртуальной машины |
| `cpu_cores` | `number` | да | Количество ядер процессора |
| `memory_gb` | `number` | да | Объём RAM в гигабайтах |
| `disk_size_gb` | `number` | да | Размер дисков в гигабайтах |
| `subnet_id` | `string` | да | ID подсети |
| `ssh_public_key` | `string` | да | Публичный SSH-ключ |
| `zone` | `string` | да | Зона доступности |
| `image_id` | `string` | да | ID образа ОС |
| `platform_id` | `string` | нет | Платформа (по умолчанию `standard-v3`) |
| `disk_type` | `string` | нет | Тип диска (по умолчанию `network-hdd`) |
| `labels` | `map(string)` | нет | Метки ресурсов |
| `allow_stopping_for_update` | `bool` | нет | Разрешить остановку при обновлении (по умолчанию `true`) |

В модуле **нет захардкоженных значений окружений** — все параметры передаются через переменные.

### Выходные значения

| Output | Описание |
|--------|----------|
| `vm_id` | Идентификатор ВМ |
| `vm_name` | Имя ВМ |
| `vm_fqdn` | FQDN ВМ |
| `vm_internal_ip` | Внутренний IP-адрес |
| `vm_external_ip` | Внешний IP-адрес (NAT) |
| `attached_disk_id` | ID подключаемого диска |
| `attached_disk_name` | Имя подключаемого диска |
| `boot_disk_id` | ID загрузочного диска |

## Конфигурации окружений

| Параметр | dev | stage | prod |
|----------|-----|-------|------|
| CPU (ядра) | 2 | 4 | 8 |
| RAM (ГБ) | 4 | 8 | 16 |
| Диск (ГБ) | 20 | 50 | 100 |
| Тип диска | network-hdd | network-ssd | network-ssd |
| Зона | ru-central1-a | ru-central1-b | ru-central1-a |

## Проверка без облака (Docker)

Установка Terraform на машине не обязательна — достаточно Docker.

```bash
cd Task1Advanced
./scripts/validate.sh
```

Скрипт выполняет:

1. `terraform fmt -check` — проверка форматирования всего кода;
2. `terraform init -backend=false` + `terraform validate` для **dev**, **stage** и **prod**.

Эти команды **не создают ресурсы в облаке** и не требуют `YC_TOKEN`. Они проверяют синтаксис, связность модулей и корректность провайдера.

Полный `terraform plan` / `apply` возможен только после настройки Yandex Cloud и подстановки реальных `folder_id`, `subnet_id` и SSH-ключа.

## Предварительные требования

1. [Terraform](https://www.terraform.io/downloads) >= 1.5.0
2. Аккаунт [Yandex Cloud](https://cloud.yandex.ru/) с настроенным CLI или переменными окружения
3. Созданные VPC, подсеть и SSH-ключ

### Аутентификация в Yandex Cloud

```bash
export YC_TOKEN=$(yc iam create-token)
export YC_CLOUD_ID=<cloud-id>
export YC_FOLDER_ID=<folder-id>
```

Либо настройте профиль через `yc init`.

## Запуск для каждого окружения

Перед применением отредактируйте `terraform.tfvars` в нужном окружении: укажите актуальные `folder_id`, `subnet_id` и `ssh_public_key`.

### Dev

```bash
cd envs/dev
terraform init
terraform plan -var-file=terraform.tfvars
terraform apply -var-file=terraform.tfvars
```

### Stage

```bash
cd envs/stage
terraform init
terraform plan -var-file=terraform.tfvars
terraform apply -var-file=terraform.tfvars
```

### Prod

```bash
cd envs/prod
terraform init
terraform plan -var-file=terraform.tfvars
terraform apply -var-file=terraform.tfvars
```

### Альтернативный способ передачи переменных

```bash
terraform apply \
  -var-file=terraform.tfvars \
  -var="subnet_id=e9b..." \
  -var="ssh_public_key=$(cat ~/.ssh/id_rsa.pub)"
```

## Удаление ресурсов

```bash
cd envs/<environment>
terraform destroy -var-file=terraform.tfvars
```

## Принципы переиспользования

- Один модуль `modules/vm` используется во всех трёх окружениях через `source = "../../modules/vm"`.
- Различия между средами задаются только в `terraform.tfvars` каждого окружения.
- Метки `environment`, `project`, `managed_by` помогают идентифицировать ресурсы в облаке.
