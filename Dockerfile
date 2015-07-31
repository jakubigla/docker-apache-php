FROM debian:latest

MAINTAINER Jakub Igla <jakub.igla@gmail.com>

RUN rm -rf /etc/apt/sources.list 
ADD sources.list /etc/apt/sources.list

RUN apt-get update && apt-get install -y \
    apache2 \
    apache2-mpm-worker \
    libapache2-mod-fastcgi \
    php5-fpm \
    php5 \
    php5-cli \
    php5-common \
    php5-curl \
    php5-gd \
    php5-imagick \
    php5-intl \
    php5-json \
    php5-mysqlnd \
    php5-redis \
    nano \
    cron

ADD apache/php5-fpm.conf /etc/apache2/conf-available/php5-fpm.conf
ADD php/mbstring.ini /etc/php5/fpm/conf.d/20-mbstring.ini
ADD php/security.ini /etc/php5/fpm/conf.d/20-security.ini

RUN rm -rf /etc/php5/cli/php.ini && \
    ln -s /etc/php5/fpm/php.ini /etc/php5/cli/php.ini

RUN echo "date.timezone = Europe/Warsaw" >>  /etc/php5/fpm/php.ini

RUN a2enmod \
        actions \
        alias \
        deflate \
        fastcgi \
        rewrite \
    && a2enconf \
        php5-fpm

RUN mkdir /scripts
ADD scripts/run.sh /scripts/run.sh
RUN chmod 755 /scripts/*.sh

RUN rm -f /var/www/html/index.html \
    && echo '<?php phpinfo(); ?>' > /var/www/html/index.php

ADD apache/default-host.conf /tmp/default-host.conf
RUN cat /tmp/default-host.conf >> /etc/apache2/apache2.conf
RUN sed -i "/^Listen/c\Listen 8080" /etc/apache2/ports.conf

EXPOSE 8080

CMD bash -C '/scripts/run.sh';'bash'

RUN apt-get autoremove && \
    apt-get autoclean && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*