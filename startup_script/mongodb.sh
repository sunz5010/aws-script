printhelp() {
    echo "
       this file is for installing mongodb and boot starting
    "
}

if [ `id -u` -ne 0 ]
then
  echo "Need root, try with sudo"
  exit 0
fi


#step 1 : change ssh port
sed -i -e 's/#Port 22/Port 22168/i' /etc/ssh/sshd_config
service sshd restart 

#step 2 : change locale
cat >> /etc/profile <<END
LC_ALL=en_US.UTF-8  
export LC_ALL
END

#step 3 : install mongodb - build mongo yum
touch /etc/yum.repos.d/mongodb-org-3.2.repo
cat >> /etc/yum.repos.d/mongodb-org-3.2.repo <<END
[mongodb-org-3.2]
name=MongoDB Repository
baseurl=https://repo.mongodb.org/yum/amazon/2013.03/mongodb-org/3.2/x86_64/
gpgcheck=0
enabled=1 
END

#step 4 :install mongodb
sudo yum install -y mongodb-org


#step 5 :allow remote connections
sed -i "s/127.0.0.1/0.0.0.0/g" /etc/mongod.conf


mkdir -p /home/mongodb

#step 6 : turn on when the machine turn on
chkconfig --levels 345 mongod on

#reboot to check all setting
reboot