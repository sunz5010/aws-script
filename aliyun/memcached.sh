if [ `id -u` -ne 0 ]
then
  echo "Need root, try with sudo"
  exit 0
fi

#check initial.sh 
if [ ! -e /tmp/initial ]; then
  ./initial.sh
fi

apt-get install -y memcached|| 
{
  echo "Could not install memcached"
}

#this is the library of memcached
apt-get install -y libmemcached|| 
{
  echo "Could not install libmemcached"
}

#setting memcached capacity
sed -i 's/-m 64/-m 600/g' /etc/memcached.conf
sed -i 's/# -c 1024/-c 102400/g' /etc/memcached.conf

sysv-rc-conf memcached on

#reboot to check all setting
reboot