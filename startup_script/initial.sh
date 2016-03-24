#-----------------
#1.update yum
#2.設訂修改時區
#3.修改上傳下載文件限制
#4.設訂編碼語言
#5.修改開放的port
#6.新增使用者(新增、載入authorized_keys、修改目錄有者、給予sudo 權限)
#7.刪除預設使用者
#8.已初始化標記
#-----------------

printhelp() {
    echo "
       this package can install nginx 、 cache 、 phalcon 、 mongodb
    "
}

while [ "$1" != "" ]; do
  case "$1" in
    -h    | --help )            echo "$(printhelp)"; exit; shift; break ;;
  esac
done

#test sudo
if [ `id -u` -ne 0 ]
then
  echo "Need root, try with sudo"
  exit 0
fi


#step 1 : update & install git
yum -y update ||
{
  echo 'can not update!'
}
#use git to install phalcon
yum -y install git

#step 2 :change time zone
cp -a /usr/share/zoneinfo/Asia/Taipei /etc/localtime 

#step 3 :change ssh port
sed -i -e "s/#Port 22/Port 22168/i" /etc/ssh/sshd_config
service sshd restart

#step 4 : change all limited option
cat >> /etc/security/limits.conf <<END
*   soft    nproc unlimited
*   hard    nproc unlimited
*   soft    nofile 10240
*   hard    nofile 20480
END

#step 5 : setting language
cat >> /etc/profile <<END
LC_ALL=en_US.UTF-8  
export LC_ALL
END

#step 6 : install nvm & npm
curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.31.0/install.sh | bash
nvm install 5 
npm install -g pm2 #global


#step 7 : initial
touch /tmp/initial

