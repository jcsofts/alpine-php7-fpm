FROM alpine:3.6

MAINTAINER JCSoft <jcsoft@aliyun.com>


ENV fpm_conf /etc/php7/php-fpm.d/www.conf



          #-e "s/;catch_workers_output\s*=\s*yes/catch_workers_output = yes/g" \
          #-e "s/pm.max_children = 5/pm.max_children = 4/g" \
          #-e "s/pm.start_servers = 2/pm.start_servers = 3/g" \
          #-e "s/pm.min_spare_servers = 1/pm.min_spare_servers = 2/g" \
          #-e "s/pm.max_spare_servers = 3/pm.max_spare_servers = 4/g" \
          #-e "s/;pm.max_requests = 500/pm.max_requests = 200/g" \
          #-e "s/user = www-data/user = nginx/g" \
          #-e "s/group = www-data/group = nginx/g" \

          #-e "s/;listen.owner = www-data/listen.owner = nginx/g" \
          #-e "s/;listen.group = www-data/listen.group = nginx/g" \
# Add repos
RUN echo "http://dl-cdn.alpinelinux.org/alpine/edge/testing" >> /etc/apk/repositories \
  && apk update \
  && apk upgrade \
  && apk add git php7 php7-phar php7-curl \
  php7-fpm php7-json php7-zlib php7-xml php7-dom php7-ctype php7-opcache php7-zip php7-iconv \
  php7-pdo php7-pdo_mysql php7-mysqli php7-pdo_sqlite php7-pdo_pgsql php7-mbstring php7-session \
  php7-gd php7-mcrypt php7-openssl php7-sockets php7-posix php7-ldap php7-simplexml \
  php7-xdebug php7-apcu \
  curl \
  openssl \
  supervisor \
  && rm -rf /var/cache/apk/* \
  && curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/bin --filename=composer \
  && mkdir -p /var/run/php-fpm \
  && mkdir -p /var/log/supervisor \
  && mkdir -p /etc/supervisor/conf.d \
  && sed -i \
          -e "s/;listen.mode = 0660/listen.mode = 0666/g" \
          -e "s/listen = 127.0.0.1:9000/listen = [::]:9000/g" \
          -e "s/^;clear_env = no$/clear_env = no/" \
          ${fpm_conf} \
  && rm -Rf /var/www/* \
  && mkdir -p /var/www/html/

ADD conf/supervisord.conf /etc/supervisord.conf

ADD scripts/start.sh /start.sh
ADD scripts/pull /usr/bin/pull
ADD scripts/push /usr/bin/push
RUN chmod 755 /usr/bin/pull \
 && chmod 755 /usr/bin/push \
 && chmod 755 /start.sh


EXPOSE 9000

CMD ["/start.sh"]
