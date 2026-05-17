#!/usr/bin/env bash
# Запуск MinIO и создание bucket для Terraform state.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"

BUCKET_NAME="${TF_STATE_BUCKET:-budushee-terraform-state}"
MINIO_ENDPOINT="${MINIO_ENDPOINT:-http://127.0.0.1:9000}"
MINIO_USER="${MINIO_ROOT_USER:-minioadmin}"
MINIO_PASSWORD="${MINIO_ROOT_PASSWORD:-minioadmin}"

echo "==> Запуск MinIO (docker compose)"
cd "${ROOT_DIR}"
docker compose up -d minio

echo "==> Ожидание готовности MinIO..."
for i in $(seq 1 30); do
  if curl -sf "${MINIO_ENDPOINT}/minio/health/live" >/dev/null 2>&1; then
    echo "MinIO доступен"
    break
  fi
  sleep 1
  if [[ "${i}" -eq 30 ]]; then
    echo "MinIO не ответил за 30 секунд" >&2
    exit 1
  fi
done

echo "==> Создание bucket: ${BUCKET_NAME}"
docker run --rm --network host --entrypoint /bin/sh \
  minio/mc:latest \
  -ec "
    mc alias set local ${MINIO_ENDPOINT} ${MINIO_USER} ${MINIO_PASSWORD}
    mc mb --ignore-existing local/${BUCKET_NAME}
    mc version enable local/${BUCKET_NAME} || true
  "

echo ""
echo "Готово. Экспортируйте credentials для Terraform:"
echo "  export AWS_ACCESS_KEY_ID=${MINIO_USER}"
echo "  export AWS_SECRET_ACCESS_KEY=${MINIO_PASSWORD}"
echo ""
echo "Скопируйте backend.hcl:"
echo "  cp envs/dev/backend.hcl.example envs/dev/backend.hcl"
