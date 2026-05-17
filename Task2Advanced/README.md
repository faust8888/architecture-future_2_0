# Задание 2. Интеграция с CI/CD и удалённым хранением состояния

Автоматизация развёртывания инфраструктуры «Будущее 2.0» через CI/CD с **удалённым Terraform state** в S3-совместимом хранилище (MinIO / Yandex Object Storage / AWS S3).

## Структура проекта

```
Task2Advanced/
├── modules/vm/                 # Модуль ВМ (из задания 1)
├── envs/
│   ├── dev/
│   ├── stage/
│   └── prod/                   # backend "s3" + отдельный key на окружение
├── config/                     # Примеры backend.hcl
├── scripts/                    # Вспомогательные скрипты
├── docker-compose.yml          # Локальный MinIO
├── .gitlab-ci.yml              # Пример CI/CD (GitLab)
└── README.md
```

## Удалённый backend (S3)

В `envs/<env>/versions.tf` настроен partial backend:

```hcl
backend "s3" {}
```

Параметры **не хранятся в коде** — передаются через `-backend-config=backend.hcl`:

| Параметр | Назначение |
|----------|------------|
| `bucket` | Имя bucket для state |
| `key` | Путь к файлу state (`envs/dev/terraform.tfstate` и т.д.) |
| `endpoints.s3` | URL S3 API (MinIO, Yandex Object Storage) |
| `use_path_style` | Обязательно для MinIO |

### Изоляция окружений

Каждое окружение использует **отдельный ключ** в одном bucket:

| Окружение | State key |
|-----------|-----------|
| dev | `envs/dev/terraform.tfstate` |
| stage | `envs/stage/terraform.tfstate` |
| prod | `envs/prod/terraform.tfstate` |

Локальный `terraform.tfstate` **не используется** и добавлен в `.gitignore`.

## Скрипты

### `scripts/setup-minio.sh`

Запускает MinIO через Docker Compose и создаёт bucket `budushee-terraform-state`.

```bash
./scripts/setup-minio.sh
export AWS_ACCESS_KEY_ID=minioadmin
export AWS_SECRET_ACCESS_KEY=minioadmin
cp envs/dev/backend.hcl.example envs/dev/backend.hcl
```

### `scripts/generate-backend-config.sh`

Генерирует `backend.hcl` / `backend.ci.hcl` из переменных окружения (для CI/CD).

```bash
export TF_STATE_BUCKET=budushee-terraform-state
export TF_STATE_ENDPOINT=http://127.0.0.1:9000
export TF_STATE_KEY=envs/dev/terraform.tfstate
./scripts/generate-backend-config.sh dev envs/dev/backend.hcl
```

Переменные:

| Переменная | По умолчанию | Описание |
|------------|--------------|----------|
| `TF_STATE_BUCKET` | — (обязательно) | Имя bucket |
| `TF_STATE_ENDPOINT` | — (обязательно) | S3 endpoint |
| `TF_STATE_KEY` | `envs/<env>/terraform.tfstate` | Ключ объекта |
| `TF_STATE_REGION` | `us-east-1` | Регион |

### `scripts/terraform-init.sh`

`terraform init` с удалённым backend для указанного окружения.

```bash
./scripts/terraform-init.sh dev
```

### `scripts/validate.sh`

Проверка синтаксиса через Docker **без** MinIO и облака:

```bash
./scripts/validate.sh
```

## Локальный запуск

### 1. MinIO + backend

```bash
cd Task2Advanced
./scripts/setup-minio.sh
export AWS_ACCESS_KEY_ID=minioadmin
export AWS_SECRET_ACCESS_KEY=minioadmin
cp envs/dev/backend.hcl.example envs/dev/backend.hcl
```

### 2. Init / Plan / Apply

```bash
cd envs/dev
terraform init -backend-config=backend.hcl
terraform plan -var-file=terraform.tfvars
terraform apply -var-file=terraform.tfvars
```

### Yandex Object Storage

Скопируйте `config/backend.yandex.hcl.example` → `envs/<env>/backend.hcl`, укажите статические ключи сервисного аккаунта:

```bash
export AWS_ACCESS_KEY_ID=<access-key>
export AWS_SECRET_ACCESS_KEY=<secret-key>
```

## CI/CD (GitLab CI)

Пример пайплайна: [`.gitlab-ci.yml`](.gitlab-ci.yml) (при необходимости перенесите в корень монорепозитория и скорректируйте пути).

### Этапы пайплайна

```mermaid
flowchart LR
  A[validate] --> B[remote_state]
  B --> C[plan]
  C --> D[apply manual]
```

| Job | Когда | Действие |
|-----|-------|----------|
| **validate** | pipeline | `fmt`, `init -backend=false`, `validate` по матрице `dev` / `stage` / `prod` |
| **remote_state** | pipeline | сервис MinIO + `init` с S3 backend, проверка отсутствия локального `terraform.tfstate` |
| **plan** | MR / default branch | `init` + `plan`, артефакт `tfplan` |
| **apply** | `when: manual` на default branch | `plan` + `apply` для выбранного окружения (`APPLY_ENV`) |

### Ручной apply

В GitLab задайте переменную **`APPLY_ENV`** (`dev`, `stage` или `prod`) при запуске manual job **apply**, либо зафиксируйте окружения отдельными job в `.gitlab-ci.yml`. Для `stage` и `prod` используйте **protected environments** и approvers в настройках проекта.

### Переменные CI/CD (GitLab: Settings → CI/CD → Variables)

| Переменная | Назначение |
|------------|------------|
| `TF_STATE_ACCESS_KEY` / `TF_STATE_SECRET_KEY` | Ключи S3 / MinIO (если не захардкожены в примере) |
| `TF_STATE_ENDPOINT` | Endpoint (prod: например `https://storage.yandexcloud.net`) |
| `TF_STATE_BUCKET` | Имя bucket для state |
| `YC_TOKEN` | Токен Yandex Cloud для реального `terraform plan`/`apply` |
| `YC_FOLDER_ID`, `YC_SUBNET_ID`, `SSH_PUBLIC_KEY` | Параметры провайдера (через `TF_VAR_*` при необходимости) |

Файл `.gitlab-ci.yml` задаёт MinIO как сервис для remote state; для продакшен-state замените endpoint и секреты на ваш Object Storage.

## Безопасность

- Секреты и `backend.hcl` **не коммитятся** (см. `.gitignore`)
- Отдельный state key на каждое окружение
- `apply` только вручную (`when: manual`) и только с защищённых веток / окружений по политике GitLab
- для `stage` и `prod` — protected environments и обязательные approvers
- `TF_IN_AUTOMATION=true` в CI
- Чувствительные переменные (`ssh_public_key`) помечены `sensitive = true`

## Проверка без облака

```bash
cd Task2Advanced
./scripts/validate.sh
```

Проверка remote state локально:

```bash
./scripts/setup-minio.sh
export AWS_ACCESS_KEY_ID=minioadmin AWS_SECRET_ACCESS_KEY=minioadmin
./scripts/terraform-init.sh dev
# Убедитесь, что terraform.tfstate не появился локально
ls envs/dev/terraform.tfstate 2>/dev/null && echo "ОШИБКА: локальный state" || echo "OK: state удалённый"
```
