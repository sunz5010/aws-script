#test sudo
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
apt-get install -y nginx || {
  echo "Could not install nginx"
}

#step 3 : install php55-fpm
apt-get install -y php5-fpm || {
  echo "Could not install php55-fpm" 
}

#step 4 : nginx compile php file
#change worker processes
cat > /etc/nginx/nginx.conf <<END
user  www-data;
worker_processes 2;
pid /run/nginx.pid;

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
  tcp_nopush on;
  tcp_nodelay on;
   
  keepalive_timeout  0;
   
  gzip  on;
  gzip_min_length 1k;
  gzip_buffers 4 16k;
  gzip_http_version 1.1;
  gzip_comp_level 2;
  gzip_types text/plain application/x-javascript text/css application/xml
  gzip_vary on;
   
  include /etc/nginx/conf.d/*.conf;
  include /etc/nginx/sites-enabled/*;
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
        fastcgi_pass unix:/var/run/php5-fpm.sock;
        fastcgi_index   index.php;
        
        include fastcgi_params;
        
        fastcgi_split_path_info       ^(.+\.php)(/.+)$;
        fastcgi_param PATH_INFO       $fastcgi_path_info;
        fastcgi_param PATH_TRANSLATED $document_root$fastcgi_path_info;
        fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
        
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

chown www-data: -R /home/www

#step 7 : create session file
mkdir /var/lib/php5/session
chown www-data: /var/lib/php/session

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
apt-get install -y php5 ||
{
  echo 'can not install php55'
}

apt-get install -y php5-memcache||
{
  echo 'can not install php5 memcache'
}

apt-get install -y php5-memcached||
{
  echo 'can not install php5 memcached'
}

apt-get install -y libapache2-mod-php5||
{
  echo 'can not install php5 mbstring'
}

apt-get install -y php5-gd||
{
  echo 'can not install php5 gd'
}

#php opcache
sed -i "s/;opcache.revalidate_freq=2/opcache.revalidate_freq=60/g" /etc/php5/fpm/php.ini
sed -i "s/;opcache.enable_cli=0/opcache.enable_cli=1/g" /etc/php5/fpm/php.ini
sed -i "s/;opcache.enable=0/opcache.enable=1/g" /etc/php5/fpm/php.ini

#Development environment => for mongodb
apt-get install -y php5-dev || 
{
  echo 'can not install php5-dev'
}

apt-get install -y libtool ||
{
  echo 'can not install libtool'  
}

#this is c compile
apt-get install -y gcc || 
{
  echo 'can not install gcc'
}

apt-get install -y php-pear ||
{
  echo 'can not install php-pear'
}

#if don't install this one , pecl can't install
apt-get install -y libssl-dev || 
{
  echo 'openssl devel can not install'
}

apt-get install -y php5-imagick || 
{
  echo 'php55-pecl-imagick can not install '
}

# apt-get install -y make ||
# {
#     echo 'can not isntall make'
# }

# yum -y install php55-pdo || {
#   echo 'php55-pdo can not install '
# } 

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
touch /etc/php5/fpm/conf.d/phalcon.ini
cat > /etc/php5/fpm/conf.d/phalcon.ini <<END
[phalcon]
extension=phalcon.so
END
touch /etc/php5/cli/conf.d/phalcon.ini
cat > /etc/php5/cli/conf.d/phalcon.ini <<END
[phalcon]
extension=phalcon.so
END

#mongodb extension
touch /etc/php5/fpm/conf.d/mongo.ini
cat > /etc/php5/fpm/conf.d/mongo.ini <<END
[mongo]
extension=mongo.so
END
touch /etc/php5/cli/conf.d/mongo.ini
cat > /etc/php5/cli/conf.d/mongo.ini <<END
[mongo]
extension=mongo.so
END

#mongo extension
touch /etc/php5/fpm/conf.d/mongodb.ini
cat > /etc/php5/fpm/conf.d/mongodb.ini <<END
[mongodb]
extension=mongodb.so
END
touch /etc/php5/cli/conf.d/mongodb.ini
cat > /etc/php5/cli/conf.d/mongodb.ini <<END
[mongodb]
extension=mongodb.so
END

#open php short tag
sed -i "s/short_open_tag = Off/short_open_tag = On/g" /etc/php5/fpm/conf.d/php.ini
sed -i "s/short_open_tag = Off/short_open_tag = On/g" /etc/php5/cli/conf.d/php.ini
echo "*/1 * * * * root /home/myscript/git_pull.sh > /tmp/git_pull.log" >> /etc/crontab 

#create a script folder
mkdir /home/myscript
touch /home/myscript/git_pull.sh
chmod +x /home/myscript/git_pull.sh
cat >> /home/myscript/git_pull.sh <<END
cd /home/www/$server
git pull
END

#install chkconfig ubuntu
apt-get install -y sysv-rc-conf ||
{
    echo 'can not install ubuntu chkconfig'
}

#step 10 : turn on nginx
service nginx start
service php-fpm start
sysv-rc-conf nginx on
sysv-rc-conf php5-fpm on

#step 11 : install phalcon
./phalcon.sh -f