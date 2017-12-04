#!/bin/bash

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
  sed -i "s/;php_flag[display_errors] = off/php_flag[display_errors] = off/g" /etc/php7/php-fpm.d/www.conf
else
 sed -i "s/;php_flag[display_errors] = off/php_flag[display_errors] = on/g" /etc/php7/php-fpm.d/www.conf
 sed -i "s/display_errors = Off/display_errors = On/g" /etc/php7/php.ini
 if [ ! -z "$ERROR_REPORTING" ]; then sed -i "s/error_reporting = E_ALL & ~E_DEPRECATED & ~E_STRICT/error_reporting = $ERROR_REPORTING/g" /etc/php7/php.ini; fi
 sed -i "s#;error_log = syslog#error_log = /var/log/php/error.log#g" /etc/php7/php.ini
fi


# Increase the memory_limit
if [ ! -z "$PHP_MEM_LIMIT" ]; then
 sed -i "s/memory_limit = 128M/memory_limit = ${PHP_MEM_LIMIT}M/g" /etc/php7/php.ini
fi

# Increase the post_max_size
if [ ! -z "$PHP_POST_MAX_SIZE" ]; then
 sed -i "s/post_max_size = 8M/post_max_size = ${PHP_POST_MAX_SIZE}M/g" /etc/php7/php.ini
fi

# Increase the upload_max_filesize
if [ ! -z "$PHP_UPLOAD_MAX_FILESIZE" ]; then
 sed -i "s/upload_max_filesize = 2M/upload_max_filesize= ${PHP_UPLOAD_MAX_FILESIZE}M/g" /etc/php7/php.ini
fi

# Enable xdebug
XdebugFile='/etc/php7/conf.d/xdebug.ini'


if [[ "$ENABLE_XDEBUG" == "1" ]] ; then
  echo "Enabling xdebug"
    # See if file contains xdebug text.
    if grep -q ";zend_extension=xdebug.so" "$XdebugFile"; then
      sed -i "s/;zend_extension=xdebug.so/zend_extension=xdebug.so/g" $XdebugFile
      if grep -q xdebug.remote_enable "$XdebugFile"; then
        echo "Xdebug remote already enabled... skipping"
      else
        echo "xdebug.remote_enable=1 "  >> $XdebugFile
        echo "xdebug.remote_log=/tmp/xdebug.log"  >> $XdebugFile
        echo "xdebug.remote_autostart=false "  >> $XdebugFile # I use the xdebug chrome extension instead of using autostart
        # echo "xdebug.remote_host=localhost "  >> $XdebugFile
        # echo "xdebug.remote_port=9000 "  >> $XdebugFile
        # NOTE: xdebug.remote_host is not needed here if you set an environment variable in docker-compose like so `- XDEBUG_CONFIG=remote_host=192.168.111.27`.
        #       you also need to set an env var `- PHP_IDE_CONFIG=serverName=docker`
      fi
    else
      echo "Xdebug already enabled... skipping"
    fi

else
  if [ -f $XdebugFile ]; then
      if grep -q ";zend_extension=xdebug.so" "$XdebugFile"; then
        echo "Xdebug already disabled... skipping"
      else
        sed -i "s/zend_extension=xdebug.so/;zend_extension=xdebug.so/g" $XdebugFile
      fi
  fi
fi



# Start supervisord and services
exec /usr/bin/supervisord -n -c /etc/supervisord.conf