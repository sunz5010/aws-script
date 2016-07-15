#this one is for manager ec2 
#1.key name
#2.setting init private machine
#3.setting webserver
#4.setting database
#5.setting memcache
#6.新建帳號帳號 & 鑰匙處理 & 初始化(初始化將刪除ec2-user文件夾)
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

#step 2 : 開NAT
echo -n 'do you wanna set NAT to private subnet(yes/no/stop)? '
read installNAT
if [ $installNAT == 'yes' ]; then
    echo -n '想對外連線的網段private subnet(含CIDR block => ex:192.168.2.0/24 ) '
    read subnetIp
    iptables -t nat -A POSTROUTING -o eth0 -s $subnetIp -j MASQUERADE
    echo "sudo iptables -t nat -A POSTROUTING -o eth0 -s $subnetIp -j MASQUERADE" >> /etc/rc.local 
    sed -i "s/net.ipv4.ip_forward = 0/net.ipv4.ip_forward = 1/g" /etc/sysctl.conf
    sysctl -p
elif [ $installNAT == 'stop' ]; then
    exit 0 ;
fi

#step 3 : init private machine
echo -n 'install init machine only (yes/no/stop)? '
read installInitMachine
if [ $installInitMachine == 'yes' ]; then
    echo -n 'initserver IP : '
    read initserver
    scp -i $key'.pem' -r initial.sh ec2-user@$initserver:/home/ec2-user
    ssh -i $key'.pem' "ec2-user@$initserver"  "sudo ./initial.sh "
elif [ $installInitMachine == 'stop' ]; then
    exit 0 ;
fi

#step 3 : webserver
echo -n 'install webserver(yes/no/stop)? '
read installWebserver
if [ $installWebserver == 'yes' ]; then
    echo -n 'webserver IP : '
    read webserver
    scp -i $key'.pem' -r initial.sh nginx.sh phalcon.sh ec2-user@$webserver:/home/ec2-user
    ssh -i $key'.pem' "ec2-user@$webserver"  "sudo ./nginx.sh "
elif [ $installWebserver == 'stop' ]; then
    exit 0 ;
fi

#step 4 : database
echo -n 'install mongodb(yes/no/stop)? '
read installMongodb
if [ $installMongodb == 'yes' ]; then
    echo -n 'database IP : '
    read database
    scp -i $key'.pem' -r initial.sh mongodb.sh ec2-user@$database:/home/ec2-user
    scp -i $key'.pem' -r ../common_script/mongoBackup.sh ec2-user@$database:/home/ec2-user
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


#step 6-0 : set up manager
echo -n 'install manager(yes/no/stop)? '
read installManager
if [ $installManager == 'yes' ]; then
    #step 6 : 新建帳戶
    echo -n 'add new user name : '
    read ACCOUNT
    while [ -z $ACCOUNT ]
    do
        echo 'need to set account'
        read ACCOUNT
    done 

    useradd $ACCOUNT
    passwd $ACCOUNT

    # 新增ssh key到新的使用者資料夾
    mkdir -p /home/$ACCOUNT/.ssh
    cp /home/ec2-user/.ssh/authorized_keys /home/$ACCOUNT/.ssh/authorized_keys
    chown $ACCOUNT: -R /home/$ACCOUNT

    # 給予新使用者sudo權限
    echo "$ACCOUNT ALL=(ALL:ALL) ALL" >> /etc/sudoers

    # 鑰匙處理 & 初始化
    cp $key'.pem' /home/$ACCOUNT/$key'.pem'
    ./initial.sh 


    #step 7 : 刪除預設使用者
    find / -user ec2-user -exec rm -r {} \;
    default=`grep -n 'ec2-user' /etc/passwd | cut -d : -f 1`
    sed "$default'd'" /etc/passwd
    rm -r /home/ec2-use
    

    #stop 8 : 重啟
    reboot
elif [ $installMemcache == 'stop' ]; then
    exit 0 ;
fi
