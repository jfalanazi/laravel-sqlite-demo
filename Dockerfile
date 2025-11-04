# ===== Stage 1: Builder =====
FROM php:8.3-cli-alpine AS builder

# أدوات أساسية + مكتبات zip
RUN apk add --no-cache git unzip libzip-dev

# إضافات PHP المطلوبة للـ Laravel/Composer
RUN docker-php-ext-install zip mbstring bcmath exif pcntl

# Composer
ENV COMPOSER_ALLOW_SUPERUSER=1
ENV COMPOSER_NO_INTERACTION=1
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

WORKDIR /app

# 1) انسخ تعريفات الاعتمادات (لتسريع الكاش)
COPY composer.json composer.lock ./

# 2) ثبّت الاعتمادات بدون سكربتات ما بعد التثبيت (تجنب package:discover هنا)
RUN composer install --no-dev --prefer-dist --no-progress --no-scripts

# 3) انسخ بقية المشروع (يضيف artisan وباقي الملفات)
COPY . .

# 4) ثبّت أي اعتمادات إضافية ظهرت بعد النسخ (مع المحافظة على no-scripts)
RUN composer install --no-dev --prefer-dist --no-progress --no-scripts

# 5) نكتشف الحِزم يدويًا الآن (artisan صار موجود)
RUN php artisan package:discover || true


# ===== Stage 2: Runtime =====
FROM php:8.3-cli-alpine

# إضافات التشغيل (SQLite وغيرها)
RUN apk add --no-cache sqlite-libs sqlite-dev
RUN docker-php-ext-install pdo_sqlite mbstring bcmath exif pcntl

WORKDIR /app
COPY --from=builder /app /app

# سكربت التشغيل
COPY ./entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENV PORT=10000
EXPOSE 10000

CMD ["/entrypoint.sh"]
