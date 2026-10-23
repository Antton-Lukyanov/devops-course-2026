#!/usr/bin/env bash
set -euo pipefail

REMOTE="devops"
REMOTE_DIR="/var/www/devops-site"
SITE_URL="https://devops.local"
CA_CERT="${HOME}/devops.crt"
ROOT="$(git rev-parse --show-toplevel)"
LOCAL_DIR="${ROOT}/site/"

MODE="deploy"
if [[ "${1:-}" == "--dry-run" && $# -eq 1 ]]; then
    MODE="dry-run"
elif [[ $# -ne 0 ]]; then
    echo "Использование: scripts/deploy.sh [--dry-run]" >&2
    exit 2
fi

if [[ ! -f "${LOCAL_DIR}index.html" ]]; then
    echo "Ошибка: отсутствует ${LOCAL_DIR}index.html" >&2
    exit 1
fi

if [[ -n "$(git -C "$ROOT" status --porcelain --untracked-files=all)" ]]; then
    echo "Ошибка: в репозитории есть незакоммиченные изменения" >&2
    exit 1
fi

if [[ ! -r "$CA_CERT" ]]; then
    echo "Ошибка: сертификат не найден: $CA_CERT" >&2
    exit 1
fi

RSYNC_SSH='ssh -o BatchMode=yes -o ConnectTimeout=5'

if [[ "$MODE" == "dry-run" ]]; then
    rsync -avz --delete --chmod=D755,F644 --dry-run -e "$RSYNC_SSH" "$LOCAL_DIR" "$REMOTE:${REMOTE_DIR}/"
    exit 0
fi

rsync -avz --delete --chmod=D755,F644 -e "$RSYNC_SSH" "$LOCAL_DIR" "$REMOTE:${REMOTE_DIR}/"

curl --fail --silent --show-error --output /dev/null -k "$SITE_URL"


printf 'Деплой выполнен, commit %s\n' "$(git -C "$ROOT" rev-parse --short HEAD)"

