printhelp() {
    echo "
       this package can install nginx 、 cache 、 phalcon 、 mongodb
       -u,    --username             Enter the Username
    "
}

while [ "$1" != "" ]; do
  case "$1" in
    -u    | --username )             ACCOUNT=$2; shift 2 ;;
    -h    | --help )            echo "$(printhelp)"; exit; shift; break ;;
  esac
done

#test sudo
if [ `id -u` -ne 0 ]
then
  echo "Need root, try with sudo"
  exit 0
fi


if [ -z $ACCOUNT ]
then
    echo 'need to set account'
    exit 0
fi

#step 1 : update 
yum -y update ||
{
  echo 'can not update!'
}

#step 2 :change time zone
cp -a /usr/share/zoneinfo/Asia/Taipei /etc/localtime 

#step 3 :change ssh port
sed -i -e 's/#Port 22/Port 22168/i' /etc/ssh/sshd_config
service sshd restart 

#step 4 : add user
useradd $ACCOUNT
passwd $ACCOUNT
#userdel -fr 'ec2-user' => this one is danger
#setting language
cat >> ~/.bashrc <<END
export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8
export LANGUAGE=en_US.UTF-8
END

source ~/.bashrc

#step 5 : add key to the new user
mkdir -p /home/$ACCOUNT/.ssh
cp /home/ec2-user/.ssh/authorized_keys /home/$ACCOUNT/.ssh/authorized_keys

#step 6 : change this folder right and owner
chown $ACCOUNT: -R  /home/$ACCOUNT/.ssh
chmod 700 /home/$ACCOUNT/.ssh

#step 7 : give new user right
cat  >> /etc/sudoers <<END
$ACCOUNT ALL=(ALL:ALL) ALL
END

#step 8 : change all limited option
cat >> /etc/security/limits.conf <<END
*   soft    nproc unlimited
*   hard    nproc unlimited
*   soft    nofile 10240
*   hard    nofile 20480
END
