FROM php:8.2-apache AS symfony-base
WORKDIR /var/www/html
ENV COMPOSER_ALLOW_SUPERUSER=1

# allow customizing the www-data user and group ids
ARG WWW_DATA_UID=1004
ARG WWW_DATA_GID=986
RUN usermod  --uid $WWW_DATA_UID www-data
RUN groupmod --gid $WWW_DATA_GID www-data

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        libxslt1-dev \
        git \
        libmagickwand-dev \
        libzip-dev \
        zip  \
        unzip \
        ghostscript \
        libicu-dev \
        libapache2-mod-xsendfile \
        netcat-traditional \
    && cp "$PHP_INI_DIR/php.ini-production" "$PHP_INI_DIR/php.ini" \
    && a2enmod rewrite headers \
    && docker-php-ext-configure intl \
    && docker-php-ext-install xsl pdo pdo_mysql zip intl \
    && pecl install imagick pcov \
    && docker-php-ext-enable imagick pcov \
    && curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer \
    && curl -sS https://get.symfony.com/cli/installer | bash \
    && mv /root/.symfony5/bin/symfony /usr/local/bin/symfony \
    && git config --global --add safe.directory /var/www/html \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# default service settings
COPY docker/docker-entrypoint.sh /docker-entrypoint.sh
COPY docker/apache.conf /etc/apache2/sites-enabled/000-default.conf
COPY docker/php.ini /usr/local/etc/php/conf.d/symfony.ini
COPY docker/image-policy.xml /etc/ImageMagick-6/policy.xml

CMD ["/docker-entrypoint.sh"]