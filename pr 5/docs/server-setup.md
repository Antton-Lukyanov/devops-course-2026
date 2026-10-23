# Конфигурация виртуальной машины devops-vm

## 1. Параметры машины
- Оперативная память: 2048 МБ
- Количество ядер: 2
- Объём диска: 25 ГБ (динамически расширяемый)

## 2. Сетевые интерфейсы
- Адаптер 1 (NAT): 10.0.2.15, доступ в интернет через проброс портов
- Адаптер 2 (Host-only): 192.168.56.101, прямой доступ с хоста

## 3. Правило проброса портов
- Порт хоста: 2222
- Порт гостя: 2222 (SSH)

## 4. Учётные записи
- student: группа student, sudo (по паролю 123)
- devops: группа devops, sudo, вход по ключу Ed25519

## 5. Служба SSH
- Порт: 2222
- Файл конфигурации: /etc/ssh/sshd_config.d/99-hardening.conf
- Изменённые директивы: PermitRootLogin no, PasswordAuthentication no, PubkeyAuthentication yes, MaxAuthTries 3, AllowUsers devops, X11Forwarding no и др.

## 6. Правила межсетевого экрана
- Политики по умолчанию: deny incoming, allow outgoing
- Правила: 2222/tcp LIMIT (SSH), 80/tcp ALLOW (HTTP), 443/tcp ALLOW (HTTPS)

## 7. Снимки состояния
- 01-clean-install (создан после установки)
- 02-keys-configured (создан после настройки ключей)
- 03-ssh-hardened (создан после усиления SSH)