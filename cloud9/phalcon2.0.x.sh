#change directory
cd ~/workspace

#複製phalcon 2.1版本
git clone --depth=1 git://github.com/phalcon/cphalcon.git --branch 2.0.x --single-branch

#編譯
cd cphalcon/build
sudo ./install

#加入php ini file
sudo sh -c "echo 'extension=phalcon.so' >> /etc/php5/mods-available/phalcon.ini"
sudo php5enmod phalcon

#移除cphalcon
cd ~/workspace
sudo rm -rf cphalcon

#安裝mongo
cd ~/workspace
sudo apt-get install -y mongodb-org
mkdir ~/workspace/mongodb
echo 'mongod --bind_ip=$IP --dbpath=mongodb --nojournal --rest "$@"' > mongod
chmod a+x mongod

#安裝nvm
curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.31.7/install.sh | bash

#移除不必要檔案
cd ~/workspace
rm -f hello-world.php

#提示安裝npm webpack pm2
echo "===========注意==========="
echo "請自行安裝npm，由於同一個terminal要重開才可以"
echo "nvm install 5"
echo "npm install -g webpack"
echo "npm install -g pm2"
echo "=========================="

#安裝預設的www資料夾
cd ~/workspace
mkdir www

#修改nginx檔案
sudo sed -i -e "s/listen 80/listen 8080/i" /etc/nginx/sites-available/default
sudo sed -i -e "s/listen \[\:\:\]\:80/listen \[\:\:\]\:8080/i" /etc/nginx/sites-available/default
sudo sed -i -e "s/root \/usr\/share\/nginx\/html;/root \/home\/ubuntu\/workspace\/www;/i" /etc/nginx/sites-available/default
sudo sed -i -e "s/index index\.html index\.htm;/index index\.php index\.html index\.htm;/i" /etc/nginx/sites-available/default

#請自行解開nginx php那段
echo "===========注意==========="
echo "請自行解開 /etc/nginx/sites-available/default 其中php那段"
echo "=========================="