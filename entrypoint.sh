#!/usr/bin/env sh
set -e

DB_FILE="/var/data/sqlite/database.sqlite"
mkdir -p /var/data/sqlite || true
[ -f "$DB_FILE" ] || touch "$DB_FILE"

php artisan storage:link || true
chmod -R 775 storage bootstrap/cache || true

# إنشاء APP_KEY إذا مهو موجود
if ! grep -q "^APP_KEY=" .env || [ -z "$(grep '^APP_KEY=' .env | cut -d= -f2)" ]; then
  php -r "file_exists('.env') || copy('.env.example', '.env');"
  php artisan key:generate --force
fi

# تشغيل المايجريشن (لو ما في جداول)
php artisan migrate --force || true

# تشغيل السيرفر المدمج
php -S 0.0.0.0:${PORT} router.php
