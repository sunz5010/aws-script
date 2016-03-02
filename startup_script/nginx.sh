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
    -u    | --username )             ACCOUNT=$2; shift 2 ;;
    -p    | --password )             PASSWORD=$2; shift 2 ;;
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
  while [ -z $ACCOUNT ]
  do
      echo 'need to set account'
      read ACCOUNT
  done
  ./initial.sh -u $ACCOUNT -p ${PASSWORD}
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
error_log  /var/log/nginx/error.log;

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
   
  keepalive_timeout  65;
   
  gzip  on;
   
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

echo -n 'please enter db IP which you want to connect? '
read DBIP

#create the file testing php and mongo
mkdir -p /home/www/$web/public
touch /home/www/$web/public/index.php
cat >> /home/www/$web/public/index.php << END
<?php
//php test
phpinfo();

//mongo test
\$dbhost = '$DBIP';
\$dbname = 'my_mongodb';

\$mongoClient = new \MongoClient('mongodb://' . \$dbhost);
\$db = \$mongoClient->\$dbname;

\$cUsers = \$db->users;
\$user = array(
    'first_name' => 'SJ',
    'last_name' => 'Mongo',
    'roles' => array('developer','bugmaker')
);

\$cUsers->save($user);
\$user = array(
    'first_name' => 'SJ',
    'last_name' => 'Mongo'
);

\$user = $cUsers->findOne($user);
echo 'mongo connect successfully if the bottom data be showed!'
print_r(\$user);
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


#step 9 : all about php
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

#step 10 : turn on nginx
service nginx start
service php-fpm start
chkconfig nginx on
chkconfig php-fpm on

#step 11 : install phalcon
./phalcon.sh -f

