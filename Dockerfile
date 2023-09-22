FROM php:8.1-fpm-alpine

ARG BUILD_DATE
ARG VCS_REF

LABEL maintainer="Dominic Taylor <dominic@yobasystems.co.uk>" \
    architecture="amd64/x86_64" \
    grav-version="1.7.42.3" \
    alpine-version="3.10.1" \
    build="22-Sep-2023" \
    org.opencontainers.image.title="alpine-grav" \
    org.opencontainers.image.description="Grav Docker image running on Alpine Linux" \
    org.opencontainers.image.authors="Lars Schlimpert <lars@disroot.org>" \
    org.opencontainers.image.vendor="Cleanminds" \
    org.opencontainers.image.version="v1.7.42.3" \
    org.opencontainers.image.url="https://hub.docker.com/repository/docker/maikfree/grav-alpine/" \
    org.opencontainers.image.source="https://github.com/Bitsongithub/grav-alpine" \
    org.opencontainers.image.revision=$VCS_REF \
    org.opencontainers.image.created=$BUILD_DATE

ENV TERM="xterm" \
    GRAV_VERSION="1.7.42.3"

RUN apk add --no-cache ca-certificates curl git less musl nginx tzdata vim yaml zip \
    bash build-base gcc wget git autoconf libmcrypt-dev libzip-dev zip \
    g++ make openssl-dev \
    php81-fpm  php81-opcache php81-json php81-zlib php81-xml php81-pdo php81-phar php81-openssl \
    php81-gd php81-iconv php81-session php81-zip \
    php81-curl php81-ctype \
    php81-intl php81-bcmath php81-dom php81-mbstring php81-simplexml php81-xmlreader && \
    rm -rf /var/cache/apk/*

RUN pecl install mcrypt && \
    docker-php-ext-enable mcrypt

RUN pecl install apcu && \
    docker-php-ext-enable apcu

RUN apk update --no-cache && \
    apk upgrade --no-cache


RUN sed -i 's/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/g' /etc/php81/php.ini && \
    sed -i 's/expose_php = On/expose_php = Off/g' /etc/php81/php.ini && \
    sed -i "s/nginx:x:100:101:nginx:\/var\/lib\/nginx:\/sbin\/nologin/nginx:x:100:101:nginx:\/usr:\/bin\/bash/g" /etc/passwd && \
    sed -i "s/nginx:x:100:101:nginx:\/var\/lib\/nginx:\/sbin\/nologin/nginx:x:100:101:nginx:\/usr:\/bin\/bash/g" /etc/passwd- && \
    ln -s /usr/local/sbin/php-fpm /sbin/php-fpm

ADD files/nginx.conf /etc/nginx/
ADD files/php-fpm.conf /etc/php81/
ADD files/run.sh /
RUN chmod +x /run.sh


EXPOSE 80
VOLUME ["/usr"]
CMD ["/run.sh"]
