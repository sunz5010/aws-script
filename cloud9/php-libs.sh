#install libs
sudo apt-get install -y php5-memcache php5-memcached libapache2-mod-php5 php5-gd php5-dev libtool php-pear libssl-dev php5-imagick php5-redis

#install mongo
sudo pecl install mongo
sudo pecl install mongodb

sudo sh -c "echo 'extension=mongo.so' >> /etc/php5/mods-available/mongo.ini"
sudo sh -c "echo 'extension=mongodb.so' >> /etc/php5/mods-available/mongodb.ini"

sudo php5enmod mongo
sudo php5enmod mongodb