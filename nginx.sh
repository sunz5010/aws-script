#test sudo
#nginx config locate => /etc/nginx/nginx.conf
#      host          => /etc/nginx/conf.d/default.conf
#
#php55-fpm config locate => /etc/php-fpm.d/www.conf
#
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

#step 1 : install nginx
yum -y install nginx || {
  echo "Could not install nginx"
}

#step 2 : install php55-fpm
yum -y install php55-fpm || {
  echo "Could not install php55-fpm" 
}

#step 3 : nginx compile php file
#change worker processes
sed -i 's/worker_processes  auto/worker_processes  2/p' nginx.conf 

#this file will not be created in AWS EC2 
#setting all base 
touch /etc/nginx/conf.d/default.conf
cat >> /etc/nginx/conf.d/default.conf <<END
server {
    # setting port and name
    listen       80;
    server_name  localhost;
    
    #delete nginx version information
    server_tokens off;
    
    #log file
    access_log /var/log/nginx/access.log;
    error_log /var/log/nginx/error.log;
    

    # where is the root directory
    root   /home/www/default;
    # default entrance name
    index  index.php index.html index.htm;
 
    #error,php setting will setting in the config's file bottom /home/www/default 
    #deny & allow don't set
    
    #this is for base setting php
    #/home/www/default/*.conf can override this one
    
    #include location
    include /home/www/default/*.conf;
}
END

#step 4 : settle entrance directory
mkdir -p /home/www/default
#setting web detail setting
touch /home/www/default/default.conf
cat >> /home/www/default/default.conf <<END
location ~* \.php$ {
  fastcgi_pass 127.0.0.1:9000;
  fastcgi_index index.php;
  fastcgi_split_path_info ^(.+\.php)(.*)$;
  include fastcgi_params;
  fastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name;
}
END
#change competence(apache=>nginx)
sed -i "s/apache/nginx/g" /etc/php-fpm-5.5.d/www.conf
chown nginx:nginx -R /home/www
#create the file testing php 
touch /home/www/default/index.php
cat >> /home/www/default/index.php << END
<?php
phpinfo();
END


#step 5 : create session file
mkdir /var/lib/php/session
chown nginx:nginx /var/lib/php/session

#step 6 : memcache's php
yum -y install php55 ||
{
  echo 'can not install php55'
}
yum -y install php55-pecl-memcache||
{
  echo 'can not install php5 memcache'
}

#step 7 : install mbstring for multi-byte
yum -y install php55-mbstring||
{
  echo 'can not install php5 memcache'
}

#step 8 : install php library
yum -y install php55-gd||
{
  echo 'can not install php library'
}


#step 9 : Development environment => for mongodb
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

pecl install mongo || 
{
  echo 'mongo can not install'
}

yum -y install php55-pecl-imagick || 
{
  echo 'php55-pecl-imagick can not install '
}

yum -y install php55-pdo || {
  echo 'php55-pdo can not install '
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

#step 4 : turn on nginx
service nginx start
service php-fpm start
chkconfig nginx one
chkconfig php-fpm on