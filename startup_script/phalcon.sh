#this is for phalcon
#bottom already install in nginx
#php55-devel php55-mysql gcc libtool

printhelp() {
    echo "
       this file is for installing phalcon but library does not be installed,
       executing this file behind nginx.sh ,
       if you only want to install this file please add -f ,
       phalcon compiling need enough memory.
    "
}

if [ "$1" != "" ]; then
    case "$1" in
        -f    | --username )             break;;
        -h    | --help )            echo "$(printhelp)"; exit; shift; break ;;
        * ) echo "wrong operating"; exit;
    esac

else
    echo "wrong operating"; exit;
fi


echo -n 'you really only want to  install this file (yes/no)?'
read FORCE

if [ $FORCE != "yes" ]; then
    exit;
fi

#use git to install phalcon
yum -y install git

git clone --depth=1 git://github.com/phalcon/cphalcon.git

cd cphalcon/build

./install

#reboot to check all setting
reboot