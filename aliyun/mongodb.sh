if [ `id -u` -ne 0 ]
then
  echo "Need root, try with sudo"
  exit 0
fi

#check initial.sh 
if [ ! -e /tmp/initial ]; then
  ./initial.sh
fi

#mongo repo
sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv EA312927
echo "deb http://repo.mongodb.org/apt/ubuntu trusty/mongodb-org/3.2 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-3.2.list
sudo apt-get update

#install mongodb
sudo apt-get install -y mongodb-org


#allow remote connections
sed -i "s/127.0.0.1/0.0.0.0/g" /etc/mongod.conf
sed -i "s/\/var\/lib\/mongo/\/home\/mongodb/" /etc/mongod.conf

#set replication Name
echo -n 'please enter the replication Name? '
read replicaName
sed -i "s/#replication:/replication:\n  replSetName: $replicaName/g" /etc/mongod.conf

#close transparent-huge-pages
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
sudo update-rc.d disable-transparent-hugepages defaults

#create fold and chown
mkdir -p /home/mongodb
chown mongodb:mongodb -R /home/mongodb

#turn on when the machine turn on
sysv-rc-conf mongod on

# #step 9 : add mongo backup
# sudo mkdir /home/myscript
# sudo mv /home/ec2-user/mongoBackup.sh /home/myscript/
# sudo chmod +x /home/myscript/mongoBackup.sh
# sudo mkdir /home/mongodbBackup
# sudo echo "00 05 * * * root /home/myscript/mongoBackup.sh" >> /etc/crontab

#add slow log
sed -i.bak "s/#operationProfiling:/&\noperationProfiling:\n  slowOpThresholdMs: 800\n  mode: slowOp/" /etc/mongod.conf

#reboot to check all setting
reboot