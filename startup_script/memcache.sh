printhelp() {
    echo "
    	this is for installing memcache , its library and
    	changing its volume (1024->10240).
    "
}

if [ `id -u` -ne 0 ]
then
  echo "Need root, try with sudo"
  exit 0
fi

yum -y install memcached|| 
{
  echo "Could not install memcached"
}
#this is the library of memcached
yum install libmemcached|| 
{
  echo "Could not install libmemcached"
}

#setting memcached capacity
sed -i 's/1024/10240/g' /etc/sysconfig/memcached

#start the memcached
service memcached start

chkconfig memcached on
