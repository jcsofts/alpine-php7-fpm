FROM alpine:3.7

MAINTAINER JCSoft <jcsoft@aliyun.com>


ENV fpm_conf /etc/php5/php-fpm.conf
ENV php_ini /etc/php5/php.ini

COPY scripts/start.sh /usr/local/bin/start.sh

# Add repos
RUN apk update \
  && apk add php5 php5-phar php5-curl php5-fpm php5-json php5-zlib php5-xml php5-xmlreader php5-xsl php5-dom php5-zip php5-iconv \
  php5-pdo php5-pdo_mysql php5-mysqli php5-pdo_sqlite php5-pdo_pgsql \
  php5-gd php5-mcrypt php5-openssl php5-sockets php5-posix php5-ldap \
  php5-apcu php5-intl php5-gmp curl supervisor openssl \
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
  && chmod 755 /usr/local/bin/start.sh \
  && ln -s /usr/bin/php5 /usr/bin/php \
  && php5 -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" \
  && php5 -r "if (hash_file('SHA384', 'composer-setup.php') === '544e09ee996cdf60ece3804abc52599c22b1f40f4323403c44d44fdfdd586475ca9813a858088ffbc1f233e9b180f061') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;" \
  && php5 composer-setup.php \
  && php5 -r "unlink('composer-setup.php');" \
  && mv composer.phar /usr/local/bin/composer
  

COPY conf/supervisord.conf /etc/supervisord.conf

#ADD scripts/pull /usr/bin/pull
#ADD scripts/push /usr/bin/


EXPOSE 9000

CMD ["/usr/local/bin/start.sh"]
