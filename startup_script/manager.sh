#this one is for manager ec2 
#1.key name
#2.取得帳號
#3.setting webserver
#4.setting database
#5.setting memcache
#6.鑰匙處理 & 初始化(初始化將刪除ec2-user文件夾)
#7.重啟

printhelp() {
    echo "
        help to send all file and execute initail.sh
    "
}

#檢測是否加上sudo
if [ `id -u` -ne 0 ]
then
  echo "Need root, try with sudo"
  exit 0
fi

#step 1 : 取得鑰匙名稱
echo -n 'key name(only name) : '
read key
while [ ! -e $key'.pem' ]
do
    echo -n 'the file does not exist!please enter again : '
    read key
done


#step 2 : 新建帳戶
echo -n 'add new user name : '
read ACCOUNT
while [ -z $ACCOUNT ]
do
    echo 'need to set account'
    read ACCOUNT
done 

useradd $ACCOUNT
passwd $ACCOUNT

#step 3 : webserver
echo -n 'install webserver(yes/no/stop)? '
read installWebserver
if [ $installWebserver == 'yes' ]; then
    echo -n 'webserver IP : '
    read webserver
    scp -i $key'.pem' -r initial.sh nginx.sh phalcon.sh ec2-user@$webserver:/home/ec2-user
    ssh -i $key'.pem' "ec2-user@$webserver"  "sudo ./nginx.sh "
fi

#step 4 : database
echo -n 'install mongodb(yes/no/stop)? '
read installMongodb
if [ $installMongodb == 'yes' ]; then
    echo -n 'database IP : '
    read database
    scp -i $key'.pem' -r initial.sh mongodb.sh ec2-user@$database:/home/ec2-user
    ssh -i $key'.pem' "ec2-user@$database"  "sudo ./mongodb.sh"
elif [ $installMongodb == 'stop' ]; then
    exit 0 ;
fi

#step 5 : memcache
echo -n 'install memcache(yes/no/stop)? '
read installMemcache
if [ $installMemcache == 'yes' ]; then
    echo -n 'memcache IP : '
    read memcache
    scp -i $key'.pem' -r initial.sh memcache.sh ec2-user@$memcache:/home/ec2-user
    ssh -i $key'.pem' "ec2-user@$memcache"  "sudo ./memcache.sh "
elif [ $installMemcache == 'stop' ]; then
    exit 0 ;
fi

#step 6 : 鑰匙處理 & 初始化
cp /home/ec2-user/package/$key'.pem' /home/$key'.pem'
./initial.sh -u $ACCOUNT 
mv /home/$key'.pem' /home/$ACCOUNT/

#step 7 : delete default user
find / -user ec2-user -exec rm -r {} \;
default=`grep -n 'ec2-user' /etc/passwd | cut -d : -f 1`
sed "$default'd'" /etc/passwd
rm -r /home/ec2-use


#stop 7 : 重啟
reboot

