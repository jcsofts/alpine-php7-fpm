FROM alpine:3.8

MAINTAINER JCSoft <jcsoft@aliyun.com>


ENV fpm_conf /etc/php7/php-fpm.d/www.conf
ENV php_ini /etc/php7/php.ini

COPY scripts/start.sh /usr/local/bin/start.sh

# Add repos
RUN apk update \
  && apk add php7-fpm php7 bash php7-curl curl openssl \
  php7-json php7-xml php7-dom php7-xmlreader php7-xmlwriter php7-xsl php7-ctype php7-opcache php7-zip php7-iconv \
  php7-pdo php7-pdo_mysql php7-mysqli php7-mbstring php7-session \
  php7-gd php7-mcrypt php7-openssl php7-sockets php7-posix php7-ldap php7-simplexml php7-tokenizer \
  php7-xdebug php7-apcu php7-fileinfo php7-imagick php7-intl php7-gmp\
  && rm -rf /var/cache/apk/* \
  && mkdir -p /var/run/php-fpm \
  && sed -i \
      -e "s/pm.max_children = 5/pm.max_children = 10/g" \
      -e "s/pm.start_servers = 2/pm.start_servers = 3/g" \
      -e "s/pm.min_spare_servers = 1/pm.min_spare_servers = 2/g" \
      -e "s/pm.max_spare_servers = 3/pm.max_spare_servers = 4/g" \
      -e "s/;pm.max_requests = 500/pm.max_requests = 200/g" \
      -e "s/;listen.mode = 0660/listen.mode = 0666/g" \
      -e "s/user = www-data/user = nginx/g" \
      -e "s/group = www-data/group = nginx/g" \
      -e "s/;listen.owner = www-data/listen.owner = nginx/g" \
      -e "s/;listen.group = www-data/listen.group = nginx/g" \
      -e "s/listen = 127.0.0.1:9000/listen = [::]:9000/g" \
      -e "s/^;clear_env = no$/clear_env = no/" \
      ${fpm_conf} \
  && sed -i \
          -e "s/;session.save_path = \"\/tmp\"/session.save_path = \"\/tmp\"/g" \
          ${php_ini} \
  && rm -Rf /var/www/* \
  && rm /etc/php7/conf.d/xdebug.ini \
  && mkdir -p /var/www/html/ \
  && chmod 755 /usr/local/bin/start.sh \
  && addgroup nginx \
  && adduser -D -S -h /var/cache/nginx -s /sbin/nologin -G nginx nginx

EXPOSE 9000

CMD ["/usr/local/bin/start.sh"]
