#!/usr/bin/env bash
# Локальная проверка Terraform без облачных credentials.
# Требуется Docker. Полный apply/plan — только с настроенным Yandex Cloud.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
TF_IMAGE="${TF_IMAGE:-hashicorp/terraform:1.9}"

echo "==> terraform fmt (check)"
docker run --rm \
  -v "${ROOT_DIR}:/workspace" \
  -w /workspace \
  "${TF_IMAGE}" \
  fmt -check -recursive

echo ""
echo "==> terraform init + validate"
for env in dev stage prod; do
  echo "--- envs/${env} ---"
  docker run --rm --entrypoint sh \
    -v "${ROOT_DIR}:/workspace" \
    -w "/workspace/envs/${env}" \
    "${TF_IMAGE}" \
    -ec "terraform init -backend=false -input=false && terraform validate"
done

echo ""
echo "OK: синтаксис и структура конфигурации корректны."
echo "Для plan/apply настройте YC_TOKEN, folder_id и subnet_id в terraform.tfvars."
