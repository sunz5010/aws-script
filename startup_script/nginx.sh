#webserver install
#1.check initial or not
#2.install nginx
#3.install php55-fpm
#4.nginx compile php file
#5.build new conf
#6.change competence
#7.create session file
#8.logrotate
#9.all about php
#10.turn on nginx
#11.install phalcon

printhelp() {
    echo "
       this file can install nginx , php55-fpm,
       php about mongodb,memcache,library,mstring,
       dealing nginx entrance directory...
    "
}

while [ "$1" != "" ]; do
  case "$1" in
    -h    | --help )            echo "$(printhelp)"; exit; shift; break ;;
  esac
done

if [ `id -u` -ne 0 ]
then
  echo "Need root, try with sudo"
  exit 0
fi

#step 1 :check initial.sh 
if [ ! -e /tmp/initial ]; then
  ./initial.sh
fi

#step 2 : install nginx
yum -y install nginx || {
  echo "Could not install nginx"
}

#step 3 : install php55-fpm
yum -y install php55-fpm || {
  echo "Could not install php55-fpm" 
}

#step 4 : nginx compile php file
#change worker processes
cat > /etc/nginx/nginx.conf <<END
user  nginx;
worker_processes 2;

#set error log position
#every nginx web to set 
#error_log  /var/log/nginx/error.log;

events {
  worker_connections  10240;
}

http {
  include       /etc/nginx/mime.types;
  default_type  application/octet-stream;
  
  log_format  main  '\$remote_addr - \$remote_user [\$time_local] "\$request" '
                      '\$status $body_bytes_sent "\$http_referer" '
                      '"\$http_user_agent" "\$http_x_forwarded_for"';
  
  sendfile        on;
   
  keepalive_timeout  0;
   
  gzip  on;
  gzip_min_length 1k;
  gzip_buffers 4 16k;
  gzip_http_version 1.1;
  gzip_comp_level 2;
  gzip_types text/plain application/x-javascript text/css application/xml
  gzip_vary on;
   
  include /etc/nginx/conf.d/*.conf;
}
END

#step 5 : build new conf
echo -n 'what web you want to create? '
read web
echo -n 'your server_name? '
read server

#this file will not be created in AWS EC2 
#setting all base 
touch /etc/nginx/conf.d/$web.conf
cat >> /etc/nginx/conf.d/$web.conf <<END
server {
    listen 80;

    server_name $server;

    index index.php index.html index.htm;

    error_log /var/log/nginx/error_$web.log;
    access_log /var/log/nginx/access_$web.log main;

    root /home/www/$web/public;

    # [phalcon part]
    #try_files \$uri \$uri/ @rewrite;
    #location @rewrite {
    #    rewrite ^(.*)$ /index.php?_url=\$1;
    #}

    location ~ \.php$ {
        fastcgi_pass    127.0.0.1:9000;
        fastcgi_index   index.php;
        fastcgi_param   SCRIPT_FILENAME \$document_root\$fastcgi_script_name;
        include fastcgi_params;
        try_files       \$uri =404;
    }

    location ~ /\.ht {
        deny all;
    }
}
END

#create the file testing php and mongo
mkdir -p /home/www/$web/public
touch /home/www/$web/public/index.php
cat >> /home/www/$web/public/index.php << END
<?php
//php test
phpinfo();

END

chown nginx:nginx -R /home/www

#step 6 :change competence(apache=>nginx)
sed -i "s/apache/nginx/g" /etc/php-fpm-5.5.d/www.conf

#step 7 : create session file
mkdir /var/lib/php/session
chown nginx:nginx /var/lib/php/session

#step 8 : logrotate
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
#creat folder to put rotate file
mkdir /var/log/nginx/rotate

#step 9 : all about php
yum -y install php55 ||
{
  echo 'can not install php55'
}

yum -y install php55-pecl-memcache||
{
  echo 'can not install php5 memcache'
}

yum -y install php55-pecl-memcached||
{
  echo 'can not install php5 memcached'
}

yum -y install php55-mbstring||
{
  echo 'can not install php55-mbstring'
}

yum -y install php55-gd||
{
  echo 'can not install php library'
}

#php opcache
yum -y install php55-opcache||
{
  echo 'can not install php opcache'
}
sed -i "s/;opcache.revalidate_freq=2/opcache.revalidate_freq=60/g" /etc/php.d/opcache.ini 
sed -i "s/;opcache.enable_cli=0/opcache.enable_cli=1/g" /etc/php.d/opcache.ini


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
pecl install mongodb || 
{
  echo 'mongodb can not install'
}

#phalcon extension
touch /etc/php.d/phalcon.ini
cat > /etc/php.d/phalcon.ini <<END
[phalcon]
extension=phalcon.so
END

#mongodb extension
touch /etc/php.d/mongo.ini
cat > /etc/php.d/mongo.ini <<END
[mongo]
extension=mongo.so
END

#mongo extension
touch /etc/php.d/mongodb.ini
cat > /etc/php.d/mongodb.ini <<END
[mongodb]
extension=mongodb.so
END

#open php short tag
sed -i "s/short_open_tag = Off/short_open_tag = On/g" /etc/php.ini
echo "*/1 * * * * root /home/myscript/git_pull.sh > /tmp/git_pull.log" >> /etc/crontab 

#create a script folder
mkdir /home/myscript
touch /home/myscript/git_pull.sh
chmod +x /home/myscript/git_pull.sh
cat >> /home/myscript/git_pull.sh <<END
cd /home/www/$server
git pull
END

#step 10 : turn on nginx
service nginx start
service php-fpm start
chkconfig nginx on
chkconfig php-fpm on

#step 11 : install phalcon
./phalcon.sh -f

