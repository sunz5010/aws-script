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
sed -i 's/worker_processes  auto/worker_processes  2/p' nginx.conf 

touch /etc/nginx/conf.d/default.conf
cat >> /etc/nginx/conf.d/default.conf <<END
server {
    listen       80;
    #server_name  localhost;

    charset utf-8;
    #delete nginx version information
    server_tokens off;
  
    root   /home/www/default;
    index  index.php index.html index.htm; 
    
    location ~ \.php$ 
    {
      try_files $uri =404;
      fastcgi_pass 127.0.0.1:9000;
      fastcgi_index index.php;
      fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
      include fastcgi_params;
    }

}
END

#step 5 : settle entrance directory
mkdir -p /home/www/default
#change competence(apache=>nginx)
sed -i "s/apache/nginx/g" /etc/php-fpm-5.5.d/www.conf
chown nginx:nginx -R /home/www

#step 4 : turn on nginx
service nginx start
service php-fpm start
chkconfig nginx on
chkconfig php-fpm on

#step 5 : memcache's php
yum -y install php55-pecl-memcache||
{
  echo 'can not install php5 memcache'
}

#step 6 : install mbstring for multi-byte
yum -y install php55-mbstring||
{
  echo 'can not install php5 memcache'
}

#step 7 : install php library
yum -y install php55-gd||
{
  echo 'can not install php library'
}


#step 8 : Development environment => for mongodb
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
pecl -y install mongo || 
{
  echo 'install mongo'
}

cat >> /etc/php.ini <<END
extension=mongo.so
END
