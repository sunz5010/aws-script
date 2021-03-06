printhelp() {
    echo "
       this file is for installing mongodb and boot starting
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

#step 3 : install mongodb - build mongo yum
touch /etc/yum.repos.d/mongodb-org-3.4.repo
cat >> /etc/yum.repos.d/mongodb-org-3.4.repo <<END
[mongodb-org-3.4]
name=MongoDB Repository
baseurl=https://repo.mongodb.org/yum/amazon/2013.03/mongodb-org/3.4/x86_64/
gpgcheck=1
enabled=1
gpgkey=https://www.mongodb.org/static/pgp/server-3.4.asc
END

#step 4 :install mongodb
sudo yum install -y mongodb-org


#step 5 :allow remote connections
sed -i "s/127.0.0.1/0.0.0.0/g" /etc/mongod.conf
sed -i "s/\/var\/lib\/mongo/\/home\/mongodb/" /etc/mongod.conf

#setp 5.5 : set replication Name
echo -n 'please enter the replication Name? '
read replicaName
sed -i "s/#replication:/replication:\n  replSetName: $replicaName/g" /etc/mongod.conf

#step 6 : close transparent-huge-pages
#reference: https://docs.mongodb.org/manual/tutorial/transparent-huge-pages/
touch /etc/init.d/disable-transparent-hugepages
cat >> /etc/init.d/disable-transparent-hugepages <<END
#!/bin/sh
### BEGIN INIT INFO
# Provides:          disable-transparent-hugepages
# Required-Start:    $local_fs
# Required-Stop:
# X-Start-Before:    mongod mongodb-mms-automation-agent
# Default-Start:     2 3 4 5
# Default-Stop:      0 1 6
# Short-Description: Disable Linux transparent huge pages
# Description:       Disable Linux transparent huge pages, to improve
#                    database performance.
### END INIT INFO

case \$1 in
  start)
    if [ -d /sys/kernel/mm/transparent_hugepage ]; then
      thp_path=/sys/kernel/mm/transparent_hugepage
    elif [ -d /sys/kernel/mm/redhat_transparent_hugepage ]; then
      thp_path=/sys/kernel/mm/redhat_transparent_hugepage
    else
      return 0
    fi

    echo 'never' > \${thp_path}/enabled
    echo 'never' > \${thp_path}/defrag

    unset thp_path
    ;;
esac
END
sudo chmod 755 /etc/init.d/disable-transparent-hugepages
sudo chkconfig --add disable-transparent-hugepages

#step 7 : create fold and chown
mkdir -p /home/mongodb
chown mongod:mongod -R /home/mongodb

#step 8 : turn on when the machine turn on
chkconfig --levels 345 mongod on

#step 9 : add mongo backup
sudo mkdir /home/myscript
sudo mv /home/ec2-user/mongoBackup.sh /home/myscript/
sudo chmod +x /home/myscript/mongoBackup.sh
sudo mkdir /home/mongodbBackup
sudo echo "00 05 * * * root /home/myscript/mongoBackup.sh" >> /etc/crontab

#step 10 : add slow log
sed -i.bak "s/#operationProfiling:/&\noperationProfiling:\n  slowOpThresholdMs: 800\n  mode: slowOp/" /etc/mongod.conf

#reboot to check all setting
reboot
