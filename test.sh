#清空iptables
iptables -t nat -F
iptables -t nat -X  
iptables -t nat -P PREROUTING ACCEPT  
iptables -t nat -P POSTROUTING ACCEPT  
iptables -t nat -P OUTPUT ACCEPT  
iptables -t mangle -F  
iptables -t mangle -X  
iptables -t mangle -P PREROUTING ACCEPT  
iptables -t mangle -P INPUT ACCEPT  
iptables -t mangle -P FORWARD ACCEPT  
iptables -t mangle -P OUTPUT ACCEPT  
iptables -t mangle -P POSTROUTING ACCEPT  
iptables -F  
iptables -X  
iptables -P FORWARD ACCEPT  
iptables -P INPUT ACCEPT  
iptables -P OUTPUT ACCEPT  
iptables -t raw -F  
iptables -t raw -X  
iptables -t raw -P PREROUTING ACCEPT  
iptables -t raw -P OUTPUT ACCEPT  
#建立热点
airmon-ng stop wlan0
ifconfig wlan0 down           #wlan0修改成你的网卡
iwconfig wlan0 mode monitor
ifconfig wlan0 up
airmon-ng start wlan0 &
sleep 2                  
gnome-terminal -x bash -c "airbase-ng -e taiwan-free -c 11 wlan0"              #按需求修改
sleep 2
ifconfig at0 up
ifconfig at0 192.168.3.1 netmask 255.255.255.0
ifconfig at0 mtu 1400
route add -net 192.168.3.0 netmask 255.255.255.0 gw 192.168.3.1
echo 1 > /proc/sys/net/ipv4/ip_forward
#配置dhcp
dhcpd -cf /etc/dhcp/dhcpd.conf -pf /var/run/dhcpd.pid at0
sleep 2
/etc/init.d/isc-dhcp-server start 
#nat
iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
iptables -A FORWARD -i wlan0 -o eth0 -j ACCEPT
iptables -A FORWARD -p tcp --syn -s 192.168.3.0/24 -j TCPMSS --set-mss 1356
