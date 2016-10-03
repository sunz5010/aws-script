#update apt
sudo apt-get update

#install
sudo apt-get -y install memcached
sudo apt-get -y install php5-memcached      
sudo apt-get -y install libmemcached-tools

#change conf
sudo sed -i 's/-m 64/-m 128/g' /etc/memcached.conf