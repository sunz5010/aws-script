#test sudo
#nginx config locate => /etc/nginx/nginx.conf
#      host          => /etc/nginx/conf.d/default.conf
#
#php55-fpm config locate => /etc/php-fpm.d/www.conf
#
#

printhelp() {
    echo "
       this file can install nginx , php55-fpm,
       php about mongodb,memcache,library,mstring,
       dealing nginx entrance directory...
    "
}

if [ `id -u` -ne 0 ]
then
  echo "Need root, try with sudo"
  exit 0
fi

#step 1 : change ssh port
sed -i -e 's/#Port 22/Port 22168/i' /etc/ssh/sshd_config
service sshd restart 

#step 2 : change locale
cat >> /etc/profile <<END
LC_ALL=en_US.UTF-8  
export LC_ALL
END

#step 3 : install nginx
yum -y install nginx || {
  echo "Could not install nginx"
}

#step 4 : install php55-fpm
yum -y install php55-fpm || {
  echo "Could not install php55-fpm" 
}

#step 5 : nginx compile php file
#change worker processes
cat > /etc/nginx/nginx.conf <<END
user  nginx;
worker_processes 2

#set error log position
error_log  /var/log/nginx/error.log;

events {
  worker_connections  10240;
}

http {
  include       /etc/nginx/mime.types;
  default_type  application/octet-stream;

   sendfile        on;
   
   keepalive_timeout  65;
   
   gzip  on;
}
END




#step 6 : build new conf
echo -n 'what web you want to create? '
read web
echo -n 'your server_name? '
read server

#this file will not be created in AWS EC2 
#setting all base 
touch /etc/nginx/conf.d/$web.conf
cat >> /etc/nginx/conf.d/$web.conf <<END
server {
    server_name $server;
    root /home/www/$web/public/;
    index index.html index.php index.htm;
 
    access_log /var/log/nginx/access.log;
    error_log /var/log/nginx/error.log;
 
    # set expiration of assets to MAX for caching
    location ~* \.(ico|css|js|gif|jpe?g|png|ogg|ogv|svg|svgz|eot|otf|woff)(\?.+)?$ {
        expires max;
        log_not_found off;
    }
 
    server_tokens off;
 
    # framework rewrite
    location / {
        try_files \$uri \$uri/ /index.php;
    }
 
    location ~* \.php$ {
        fastcgi_pass 127.0.0.1:9000;
        fastcgi_index index.php;
        fastcgi_split_path_info ^(.+\.php)(.*)$;
        include fastcgi_params;
        fastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name;
    }
}
END

#create the file testing php 
mkdir -p /home/www/$web/public
touch /home/www/$web/public/index.php
cat >> /home/www/$web/index.php << END
<?php
phpinfo();
END
chown nginx:nginx -R /home/www


#step 7 :change competence(apache=>nginx)
sed -i "s/apache/nginx/g" /etc/php-fpm-5.5.d/www.conf

#step 8 : create session file
mkdir /var/lib/php/session
chown nginx:nginx /var/lib/php/session


#step 9 : logrotate
cat > /etc/logrotate.d/nginx <<END
/var/log/nginx/*log{
  create 0644 nginx nginx
  daily
  rotate 10
    dateext
    olddir rotate
  missingok
  notifempty
    #compress
  sharedscripts
  postrotate
    /etc/init.d/nginx reopen_logs
  endscript
}
END


#step 10 : all about php
yum -y install php55 ||
{
  echo 'can not install php55'
}

yum -y install php55-pecl-memcache||
{
  echo 'can not install php5 memcache'
}

yum -y install php55-mbstring||
{
  echo 'can not install php5 memcache'
}

yum -y install php55-gd||
{
  echo 'can not install php library'
}


#Development environment => for mongodb
yum -y install php55-devel || 
{
  echo 'can not install php55-devel'
}

yum -y install libtool ||
{
  echo 'can not install libtool'  
}

#this is c compile
yum -y install gcc || 
{
  echo 'can not install gcc'
}

yum -y install php-pear ||
{
  echo 'can not install php-pear'
}

#if don't install this one , pecl can't install
yum -y install openssl-devel || 
{
  echo 'openssl-devel can not install'
}

yum -y install php55-pecl-imagick || 
{
  echo 'php55-pecl-imagick can not install '
}

yum -y install php55-pdo || {
  echo 'php55-pdo can not install '
} 
# need install behind pdo
pecl install mongo || 
{
  echo 'mongo can not install'
}

cat >> /etc/php.ini <<END
extension=mongo.so
END

#phalcon extension
touch /etc/php.d/phalcon.ini
cat > /etc/php.d/phalcon.ini <<END
[phalcon]
extension=phalcon.so
END

#step 11 : turn on nginx
service nginx start
service php-fpm start
chkconfig nginx on
chkconfig php-fpm on

./phalcon.sh

