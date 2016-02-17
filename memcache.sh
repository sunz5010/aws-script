
if [ `id -u` -ne 0 ]
then
  echo "Need root, try with sudo"
  exit 0
fi

yum -y install memcached|| 
{
  echo "Could not install memcached"
}
yum install libmemcached|| 
{
  echo "Could not install libmemcached"
}
#set port and other setting


#start the memcached
service memcached start

chkconfig memcached on

#setting memcached capacity
sed -i 's/1024/10240/g' /etc/sysconfig/memcached