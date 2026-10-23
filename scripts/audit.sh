echo "[5] Контейнеризация"
check "Служба docker активна" "active" "$(systemctl is-active docker)"
check "СУБД healthy" "healthy" "$(docker inspect -f '{{.State.Health.Status}}' app-db-1 2>/dev/null || echo 'not found')"
bad_ports=$(sudo ss -tlnH | awk '$4 ~ /:(5000|5432)$/ && $4 !~ /^127[.]0[.]0[.]1:/ {print $4}')
check "Порты 5000 и 5432 только на localhost" "safe" "$( [ -z "$bad_ports" ] && echo safe || echo exposed )"
env_perms=$(stat -c '%a' ~/app/.env 2>/dev/null || echo "not found")
check "Права .env равны 600" "600" "$env_perms"#!/usr/bin/env bash
set -uo pipefail

PASS=0; FAIL=0

check() {
  local desc="$1" expected="$2" actual="$3"
  if [[ "$actual" == "$expected" ]]; then
    echo " [OK]  $desc"; ((PASS++))
  else
    echo " [FAIL] $desc (ожидалось: '$expected', получено: '$actual')"; ((FAIL++))
  fi
}

echo "Аудит конфигурации: $(hostname -f), $(date '+%Y-%m-%d %H:%M')"

echo "[1] Служба SSH"
check "Вход от имени root запрещён" "no" "$(sudo sshd -T | awk '/^permitrootlogin/{print $2}')"
check "Парольная аутентификация отключена" "no" "$(sudo sshd -T | awk '/^passwordauthentication/{print $2}')"
# TODO 1: проверьте, что значение параметра port отлично от 22
check "Порт SSH нестандартный (не 22)" "yes" "$( [ "$(sudo sshd -T | awk '/^port/{print $2}')" != "22" ] && echo yes || echo no )"
# TODO 2: проверьте, что значение параметра maxauthtries равно 3
check "MaxAuthTries равно 3" "3" "$(sudo sshd -T | awk '/^maxauthtries/{print $2}')"

check "Межсетевой экран активен" "active" "$(sudo ufw status | awk '/^Status:/{print $2}')"
# TODO 3: проверьте, что политика по умолчанию для входящего трафика равна deny
check "Политика UFW incoming по умолчанию deny" "deny" "$(sudo ufw status verbose | awk '/^Default:/{print $2}')"

echo "[3] Учётные записи"
awk -F: ' $3>=1000 && $3<65534 {printf " %s (uid=%s)\n",$1,$3}' /etc/passwd

echo "[5] Контейнеризация"
check "Служба docker активна" "active" "$(systemctl is-active docker)"
check "СУБД healthy" "healthy" "$(docker inspect -f '{{.State.Health.Status}}' app-db-1 2>/dev/null || echo 'not found')"
bad_ports=$(sudo ss -tlnH | awk '$4 ~ /:(5000|5432)$/ && $4 !~ /^127[.]0[.]0[.]1:/ {print $4}')
check "Порты 5000 и 5432 только на localhost" "safe" "$( [ -z "$bad_ports" ] && echo safe || echo exposed )"
env_perms=$(stat -c '%a' ~/app/.env 2>/dev/null || echo "not found")
check "Права .env равны 600" "600" "$env_perms"

echo "Пройдено: $PASS, не пройдено: $FAIL"
[[ $FAIL -eq 0 ]] && exit 0 || exit 1
