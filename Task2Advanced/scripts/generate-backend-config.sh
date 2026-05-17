#!/usr/bin/env bash
# Генерация backend.hcl из переменных окружения (для CI/CD).
# Использование: ./scripts/generate-backend-config.sh <environment> <output_path>
set -euo pipefail

ENVIRONMENT="${1:?Укажите окружение: dev, stage или prod}"
OUTPUT="${2:-backend.ci.hcl}"

: "${TF_STATE_BUCKET:?TF_STATE_BUCKET не задан}"
: "${TF_STATE_ENDPOINT:?TF_STATE_ENDPOINT не задан}"
: "${TF_STATE_REGION:=us-east-1}"

KEY="${TF_STATE_KEY:-envs/${ENVIRONMENT}/terraform.tfstate}"

cat > "${OUTPUT}" <<EOF
bucket                      = "${TF_STATE_BUCKET}"
key                         = "${KEY}"
region                      = "${TF_STATE_REGION}"
endpoints                   = { s3 = "${TF_STATE_ENDPOINT}" }
skip_credentials_validation = ${TF_STATE_SKIP_CREDS_VALIDATION:-true}
skip_metadata_api_check     = ${TF_STATE_SKIP_METADATA:-true}
skip_region_validation      = ${TF_STATE_SKIP_REGION:-true}
skip_requesting_account_id  = ${TF_STATE_SKIP_ACCOUNT_ID:-true}
skip_s3_checksum            = ${TF_STATE_SKIP_CHECKSUM:-true}
use_path_style              = ${TF_STATE_USE_PATH_STYLE:-true}
EOF

echo "Создан ${OUTPUT} для окружения ${ENVIRONMENT}"
