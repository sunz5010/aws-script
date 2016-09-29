#change directory
cd ~/workspace

#複製phalcon 2.1版本
git clone --depth=1 git://github.com/phalcon/cphalcon.git --branch 2.1.x --single-branch

#編譯
cd cphalcon/build
sudo ./install

#加入php ini file
sudo echo "extension=phalcon.so" > sudo vim /etc/php5/fpm/conf.d/phalcon.ini
sudo echo "extension=phalcon.so" > sudo vim /etc/php5/cli/conf.d/phalcon.ini

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

#提示安裝npm
echo "===========注意==========="
echo "請自行安裝npm，由於同一個terminal要重開才可以"
echo "nvm install 5"
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