echo -n 'you really want to  install phalcon.sh (yes/no)?'
read FORCE

if [ $FORCE != "yes" ]; then
    exit;
fi

#add swap ,prevent the swap insufficient 
mkdir -p /var/cache/swap/
dd if=/dev/zero of=/var/cache/swap/swap0 bs=1M count=512
chmod 0600 /var/cache/swap/swap0
mkswap /var/cache/swap/swap0 
swapon /var/cache/swap/swap0

git clone --depth=1 git://github.com/phalcon/cphalcon.git

cd cphalcon/build

./install

#remove swap after installing
swapon /var/cache/swap/swap0
rm /var/cache/swap

#reboot to check all setting
reboot