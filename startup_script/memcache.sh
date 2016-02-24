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

#change ssh port
sed -i -e 's/#Port 22/Port 22168/i' /etc/ssh/sshd_config
service sshd restart 

#change locale
cat >> /etc/profile <<END
LC_ALL=en_US.UTF-8  
export LC_ALL
END

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


chkconfig memcached on

#reboot to check all setting
reboot