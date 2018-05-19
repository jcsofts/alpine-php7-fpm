FROM alpine:3.7

MAINTAINER JCSoft <jcsoft@aliyun.com>


ENV fpm_conf /etc/php7/php-fpm.d/www.conf
ENV php_ini /etc/php7/php.ini

COPY scripts/start.sh /usr/local/bin/start.sh

# Add repos
RUN echo "http://dl-cdn.alpinelinux.org/alpine/edge/testing" >> /etc/apk/repositories \
  && apk update \
  && apk add php7 php7-phar php7-curl \
  php7-fpm php7-json php7-zlib php7-xml php7-xmlreader php7-xmlwriter php7-xsl php7-dom php7-ctype php7-opcache php7-zip php7-iconv \
  php7-pdo php7-pdo_mysql php7-mysqli php7-pdo_sqlite php7-pdo_pgsql php7-mbstring php7-session \
  php7-gd php7-mcrypt php7-openssl php7-sockets php7-posix php7-ldap php7-simplexml php7-tokenizer \
  php7-xdebug php7-apcu php7-fileinfo php7-imagick php7-intl php7-gmp \
  curl supervisor composer \
  openssl \
  && rm -rf /var/cache/apk/* \
  && mkdir -p /var/run/php-fpm \
  && sed -i \
          -e "s/;listen.mode = 0660/listen.mode = 0666/g" \
          -e "s/listen = 127.0.0.1:9000/listen = [::]:9000/g" \
          -e "s/^;clear_env = no$/clear_env = no/" \
          ${fpm_conf} \
  && sed -i \
          -e "s/;session.save_path = \"\/tmp\"/session.save_path = \"\/tmp\"/g" \
          ${php_ini} \
  && rm -Rf /var/www/* \
  && mkdir -p /var/www/html/ \
  && rm -rf /var/cache/apk/* \
  && chmod 755 /usr/local/bin/start.sh 

COPY conf/supervisord.conf /etc/supervisord.conf

#ADD scripts/pull /usr/bin/pull
#ADD scripts/push /usr/bin/


EXPOSE 9000

CMD ["/usr/local/bin/start.sh"]
