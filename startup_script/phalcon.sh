#this is for phalcon
#bottom already install in nginx
#php55-devel php55-mysql gcc libtool

printhelp() {
    echo "
       this file is for installing phalcon but library does not be installed,
       executing this file behind nginx.sh , 
       phalcon compiling need enough memory.
    "
}

if [ `id -u` -ne 0 ]
then
  echo "Need root, try with sudo"
  exit 0
fi

#use git to install phalcon
yum -y install git

git clone --depth=1 git://github.com/phalcon/cphalcon.git

cd cphalcon/build

./install

#reset nginx
service nginx start
service php-fpm start