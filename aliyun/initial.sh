#test sudo
if [ `id -u` -ne 0 ]
then
  echo "Need root, try with sudo"
  exit 0
fi

#update
apt-get update ||
{
  echo 'can not update!'
}

#intall git
apt-get install -y git

#set git user name and email
git config --global user.name "ubuntu ecloud env"
git config --global user.email "no@email.com"

#change time zone
ln -fs /usr/share/zoneinfo/Asia/Taipei /etc/localtime

#change all limited option
cat >> /etc/security/limits.conf <<END
*   soft    nproc unlimited
*   hard    nproc unlimited
*   soft    nofile 32000
*   hard    nofile 32000
END

#setting language
sudo locale-gen "en_US.UTF-8"
sudo dpkg-reconfigure locales

#install nvm & npm
sudo curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.31.0/install.sh | bash
sudo nvm install 5 
sudo npm install -g pm2 #global

#initial
touch /tmp/initial