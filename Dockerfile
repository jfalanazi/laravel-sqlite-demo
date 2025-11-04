# ===== Stage 1: Builder =====
FROM php:8.3-cli-alpine AS builder

# تثبيت الأدوات والإضافات اللازمة لـ composer
RUN apk add --no-cache git unzip libzip-dev
RUN docker-php-ext-install zip

# إضافة composer
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

WORKDIR /app

# نسخ ملفات التعريف فقط أولاً لتسريع الكاش
COPY composer.json composer.lock ./

# تثبيت الاعتمادات بدون dev
RUN composer install --no-dev --prefer-dist --no-interaction --no-progress

# نسخ بقية المشروع الآن
COPY . .

# اكتشاف الحزم (الآن artisan موجود بعد النسخ)
RUN php artisan package:discover || true

# ===== Stage 2: Runtime =====
FROM php:8.3-cli-alpine

# تثبيت إضافات SQLite
RUN apk add --no-cache sqlite-libs sqlite-dev
RUN docker-php-ext-install pdo_sqlite

WORKDIR /app
COPY --from=builder /app /app

# نسخ سكربت التشغيل
COPY ./entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENV PORT=10000
EXPOSE 10000

CMD ["/entrypoint.sh"]
