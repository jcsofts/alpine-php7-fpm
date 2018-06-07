#!/bin/sh

# Disable Strict Host checking for non interactive git clones

mkdir -p -m 0700 /root/.ssh
# Prevent config files from being filled to infinity by force of stop and restart the container 
echo "" > /root/.ssh/config
echo -e "Host *\n\tStrictHostKeyChecking no\n" >> /root/.ssh/config

if [ ! -z "$SSH_KEY" ]; then
 echo $SSH_KEY > /root/.ssh/id_rsa.base64
 base64 -d /root/.ssh/id_rsa.base64 > /root/.ssh/id_rsa
 chmod 600 /root/.ssh/id_rsa
fi


# Display PHP error's or not
if [[ "$ERRORS" != "1" ]] ; then
  sed -i "s/;php_flag\[display_errors\] = off/php_flag\[display_errors\] = off/g" /etc/php5/php-fpm.conf
else
 sed -i "s/;php_flag\[display_errors\] = off/php_flag\[display_errors\] = on/g" /etc/php5/php-fpm.conf
 sed -i "s#;php_admin_value\[error_log\] = /var/log/php7/\$pool.error.log#php_admin_value\[error_log\] = /var/log/php/\$pool.error.log#g" /etc/php5/php-fpm.conf
 sed -i "s/display_errors = Off/display_errors = On/g" /etc/php5/php.ini
 if [ ! -z "$ERROR_REPORTING" ]; then sed -i "s/error_reporting = E_ALL & ~E_DEPRECATED & ~E_STRICT/error_reporting = $ERROR_REPORTING/g" /etc/php5/php.ini; fi
 sed -i "s#;error_log = syslog#error_log = /var/log/php/error.log#g" /etc/php5/php.ini
fi


# Increase the memory_limit
if [ ! -z "$PHP_MEM_LIMIT" ]; then
 sed -i "s/memory_limit = 128M/memory_limit = ${PHP_MEM_LIMIT}M/g" /etc/php5/php.ini
fi

# Increase the post_max_size
if [ ! -z "$PHP_POST_MAX_SIZE" ]; then
 sed -i "s/post_max_size = 8M/post_max_size = ${PHP_POST_MAX_SIZE}M/g" /etc/php5/php.ini
fi

# Increase the upload_max_filesize
if [ ! -z "$PHP_UPLOAD_MAX_FILESIZE" ]; then
 sed -i "s/upload_max_filesize = 2M/upload_max_filesize= ${PHP_UPLOAD_MAX_FILESIZE}M/g" /etc/php5/php.ini
fi

# Increase the max_execution_time
if [ ! -z "$PHP_MAX_EXECUTION_TIME" ]; then
 sed -i "s/max_execution_time = 30/max_execution_time = ${PHP_MAX_EXECUTION_TIME}/g" /etc/php5/php.ini
fi


# Start supervisord and services
exec /usr/bin/supervisord -n -c /etc/supervisord.conf
#exec /usr/sbin/php-fpm7 --nodaemonize
