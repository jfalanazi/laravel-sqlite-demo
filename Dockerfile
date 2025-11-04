# قاعدة واحدة تكفي وتسهّل البناء على Render
FROM php:8.3-cli-alpine

# أدوات وتبعيات البناء + مكتبات الامتدادات
RUN apk add --no-cache \
    git unzip \
    libzip-dev \
    sqlite-dev \
    oniguruma-dev \
    $PHPIZE_DEPS

# ثبّت امتدادات PHP المطلوبة
# ملاحظة: ترتيب التثبيت مهم أحيانًا مع zip/libzip
RUN docker-php-ext-install \
    pdo_sqlite \
    zip \
    bcmath \
    exif \
    pcntl \
    mbstring

# Composer
ENV COMPOSER_ALLOW_SUPERUSER=1 \
    COMPOSER_NO_INTERACTION=1
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

WORKDIR /app

# ثبّت الاعتمادات بدون سكربتات أولًا (لنتفادى تشغيل artisan قبل نسخ المشروع)
COPY composer.json composer.lock ./
RUN composer install --no-dev --prefer-dist --no-progress --no-scripts

# انسخ بقية المشروع وثبّت مرة أخرى (بدون سكربتات)
COPY . .
RUN composer install --no-dev --prefer-dist --no-progress --no-scripts \
 && php artisan package:discover || true

# سكربت التشغيل
COPY ./entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENV PORT=10000
EXPOSE 10000
CMD ["/entrypoint.sh"]
