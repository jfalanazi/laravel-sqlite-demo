#!/usr/bin/env sh
set -e

DB_FILE="/var/data/sqlite/database.sqlite"
mkdir -p /var/data/sqlite || true
[ -f "$DB_FILE" ] || touch "$DB_FILE"

# أنشئ .env إن لم يوجد
if [ ! -f .env ]; then
  php -r "copy('.env.example', '.env');"
fi

php artisan storage:link || true
chmod -R 775 storage bootstrap/cache || true

# ولّد APP_KEY إذا كان مفقود/فارغ
if ! grep -q "^APP_KEY=" .env || [ -z "$(grep '^APP_KEY=' .env | cut -d= -f2)" ]; then
  php artisan key:generate --force
fi

# شغّل المايجريشن
php artisan migrate --force || true

# شغّل السيرفر مع الراوتر المخصص
php -S 0.0.0.0:${PORT} router.php
