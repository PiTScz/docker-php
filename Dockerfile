FROM php:8.4.4-fpm

ARG TIMEZONE="Europe/Prague"

LABEL maintainer="radek.hrebecek@pits.cz"
LABEL org.opencontainers.image.source="https://github.com/PiTScz/docker-php"

COPY config/php.ini /usr/local/etc/php/conf.d/docker-php-config.ini

RUN apt-get update && apt-get install -y \
    gnupg \
    g++ \
    procps \
    openssl \
    curl \
    git \
    zip \
    unzip \
    libpq-dev \
    zlib1g-dev \
    libzip-dev \
    libjpeg-dev\
    libfreetype6-dev \
    libpng-dev \
    libicu-dev  \
    libonig-dev \
    libxslt1-dev \
    acl

RUN docker-php-ext-configure pgsql -with-pgsql=/usr/local/pgsql \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install pdo pdo_pgsql pgsql pdo_mysql mysqli zip xsl intl opcache exif mbstring gd

RUN pecl install xdebug \
    && docker-php-ext-enable xdebug \
    && echo "xdebug.mode=debug" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini \
    && echo "xdebug.client_host = host.docker.internal" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini

# Set timezone
RUN ln -snf /usr/share/zoneinfo/${TIMEZONE} /etc/localtime && echo ${TIMEZONE} > /etc/timezone \
    && printf '[PHP]\ndate.timezone = "%s"\n', ${TIMEZONE} > /usr/local/etc/php/conf.d/tzone.ini \
    && "date"

COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

ENV PATH=$PATH:/root/composer/vendor/bin COMPOSER_ALLOW_SUPERUSER=1

WORKDIR "/var/www"
