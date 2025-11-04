# ===== Builder =====
FROM php:8.3-cli-alpine AS builder
RUN apk add --no-cache git unzip libzip-dev
RUN docker-php-ext-install zip
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer
WORKDIR /app
COPY composer.json composer.lock ./
RUN composer install --no-dev --prefer-dist --no-interaction --no-progress
COPY . .
RUN composer install --no-dev --prefer-dist --no-interaction --no-progress
RUN php artisan package:discover || true

# ===== Runtime =====
FROM php:8.3-cli-alpine
RUN apk add --no-cache sqlite-libs sqlite-dev
RUN docker-php-ext-install pdo_sqlite
WORKDIR /app
COPY --from=builder /app /app

COPY ./entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENV PORT=10000
EXPOSE 10000
CMD ["/entrypoint.sh"]
