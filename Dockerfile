FROM php:7.4.5-fpm-alpine

ARG TIMEZONE="UTC"

SHELL ["sh", "-eo", "pipefail", "-c"]

# install composer and extensions: pdo_pgsql, intl, zip
RUN apk update && \
    apk add --no-cache -q \
    $PHPIZE_DEPS \
    bash \
    git \
    subversion \
    zip \
    unzip \
    postgresql-dev \
    icu-dev \
    libzip-dev \
    openssh-client \
    && \
    curl -sS https://getcomposer.org/installer | \
    php -- --install-dir=/usr/local/bin --filename=composer && \
    docker-php-ext-configure pdo_pgsql --with-pdo-pgsql && \
    docker-php-ext-configure intl && \
    docker-php-ext-configure zip && \
    docker-php-ext-install pdo_pgsql && \
    docker-php-ext-install intl && \
    docker-php-ext-install zip && \
    rm -rf /var/cache/apk/*

# set timezone
RUN ln -snf /usr/share/zoneinfo/${TIMEZONE} /etc/localtime && \
    echo ${TIMEZONE} > /etc/timezone && \
    printf '[PHP]\ndate.timezone = "%s"\n', "$TIMEZONE" > \
    /usr/local/etc/php/conf.d/tzone.ini && "date"

# set memory limit
RUN echo "memory_limit=512M" > /usr/local/etc/php/conf.d/memory-limit.ini

# hide X-Powered-By in reponse header
RUN echo "expose_php=off" > /usr/local/etc/php/conf.d/expose.ini

# automatically add new host keys to the user known hosts
RUN printf "Host *\n    StrictHostKeyChecking no" > /etc/ssh/ssh_config

RUN mkdir /app
WORKDIR /app

COPY . .

ENV APP_ENV=prod
RUN composer install --optimize-autoloader --no-dev

# change owner 'var' directory and mkdir 'var/repo' and change user to '82'='www-date' to be able to write the logfiles
## doesn't work on 'var' with normal user, need 'chown' as 'root'.
RUN chown -R 82:82 /app/var
#RUN mkdir /app/var/repo
RUN chown -R 82:82 /app/var/repo

# RUN "apk add" to install yacron to sudo with user 'www-data'
RUN apk add python3 python3-dev py3-pip
RUN pip3 install pipx
RUN pipx install yacron

# for yacron cron, need yml file to start yacron (in background) and to read /tmp/yacron.yml
ADD yacron.yml /tmp/

