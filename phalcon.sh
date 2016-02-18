#this is for phalcon
#bottom already install in nginx
#php55-devel php55-mysql gcc libtool

printhelp() {
    echo "
       this file is for installing phalcon but library does not be installed,
       if you need those , you have to install by yourself.
    "
}

if [ `id -u` -ne 0 ]
then
  echo "Need root, try with sudo"
  exit 0
fi

#use git to install phalcon
yum install git

git clone --depth=1 git://github.com/phalcon/cphalcon.git

cd cphalcon/build

read -p 'do you want to install cache?:(y/n) ' INSTALLCACHE
if [ $INSTALLNGINX == 'y' ] || [ $INSTALLNGINX == 'Y' ]
then
 ./install
fi


cat >> /etc/php.ini <<END
extension=phalcon.so
END

#this is for phalcon connect mongod
#echo 'mongod --bind_ip=$IP --dbpath=data --nojournal --rest "$@"' > mongod

#if [ -e mongod ]
#then
#    echo 'the file does not exist'
#    exit 0
#else
#    chmod a+x mongod    
#fi