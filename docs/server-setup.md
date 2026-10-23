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
- student: группа student, sudo (по паролю)
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
- 04-nginx-https (создан после настройки HTTPS)

## 8. Веб-сервер
- Устанавливаемый пакет: nginx
- Путь к конфигурации ресурса: /etc/nginx/sites-available/devops-site
- Каталог ресурса: /var/www/devops-site, владелец: devops, права: 755
- Путь к сертификату: /etc/ssl/certs/devops.crt (644)
- Путь к ключу: /etc/ssl/private/devops.key (600, владелец root)
- Команда формирования сертификата: sudo openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /etc/ssl/private/devops.key -out /etc/ssl/certs/devops.crt -subj "/CN=devops.local" -addext "subjectAltName=DNS:devops.local"
- Срок действия: 365 дней

## 9. Контейнеризация
- Docker Engine установлен из официального репозитория, версия 29.x
- Учётная запись devops состоит в группе docker
- Расположение проекта на сервере: ~/app
- Расположение файла .env: ~/app/.env, права 600
- Публикуемые порты: 127.0.0.1:5000 (приложение), 5432 не публикуется
- Именованный том: app_db_data
- Конфигурация обратного прокси: location /app/ { proxy_pass http://127.0.0.1:5000/; ... }
