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

#step 1 : install mongodb - build mongo yum
touch /etc/yum.repos.d/mongodb-org-3.2.repo
cat >> /etc/yum.repos.d/mongodb-org-3.2.repo <<END
[mongodb-org-3.2]
name=MongoDB Repository
baseurl=https://repo.mongodb.org/yum/amazon/2013.03/mongodb-org/3.2/x86_64/
gpgcheck=0
enabled=1 
END

#step 2 :install mongodb
sudo yum install -y mongodb-org

#step 3 :mongo start
service mongod start

mkdir -p /home/mongodb

#step 4 : turn on when the machine turn on
chkconfig --levels 345 mongod on
