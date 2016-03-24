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
sed -i "s/\/var\/lib\/mongo/\/home\/mongodb/" /etc/mongod.conf

#step 6 : create fold and chown
mkdir -p /home/mongodb
chown mongod:mongod -R /home/mongodb

#step 7 : turn on when the machine turn on
chkconfig --levels 345 mongod on

#reboot to check all setting
reboot
