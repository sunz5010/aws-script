printhelp() {
    echo "
    	this is for installing memcache , its library and
    	changing its volume (1024->10240).
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

#check initial.sh 
if [ ! -e /tmp/initial ]; then
  ./initial.sh
fi

yum -y install memcached|| 
{
  echo "Could not install memcached"
}

#this is the library of memcached
yum -y install libmemcached|| 
{
  echo "Could not install libmemcached"
}

#setting memcached capacity
sed -i 's/1024/10240/g' /etc/sysconfig/memcached
sed -in '/CACHESIZE/d' /etc/sysconfig/memcached
echo 'CACHESIZE="600"' >> /etc/sysconfig/memcached


chkconfig memcached on

#reboot to check all setting
reboot
