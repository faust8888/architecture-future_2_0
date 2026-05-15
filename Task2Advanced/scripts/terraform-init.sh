#!/usr/bin/env bash
# terraform init с удалённым backend для указанного окружения.
set -euo pipefail

ENVIRONMENT="${1:?Укажите окружение: dev, stage или prod}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
ENV_DIR="${ROOT_DIR}/envs/${ENVIRONMENT}"
BACKEND_CONFIG="${BACKEND_CONFIG:-${ENV_DIR}/backend.hcl}"

if [[ ! -f "${BACKEND_CONFIG}" ]]; then
  echo "Файл ${BACKEND_CONFIG} не найден." >&2
  echo "Скопируйте backend.hcl.example или запустите generate-backend-config.sh" >&2
  exit 1
fi

cd "${ENV_DIR}"
terraform init \
  -backend-config="${BACKEND_CONFIG}" \
  -input=false \
  -reconfigure

echo "Init завершён. State хранится удалённо (не локально)."
