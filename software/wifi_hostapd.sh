#!/usr/bin/env bash
#configure hotspot

#
#
# This doesnt works
# you have to recompile some shit
# as suggested in https://wannabe-nerd.tweakblogs.net/blog/10870/wifi-access-point-using-a-realtek-8192cu-based-usb-wifi-dongle-with-a-raspberry-pi.html
#
#  ln -s ~/linux/arch/arm ~/linux/arch/armv7l
# instead of
#  ln -s ~/linux/arch/arm ~/linux/arch/armv6l
#
# also
# echo 1 > /proc/sys/net/ipv4/ip_forward





# First run


IP="192.168.6.1"
DHCP_RANGE="192.168.6.100,192.168.6.200"
#HOSTAPD_DRIVER="rtl871xdrv" #nl80211 rPI3 integrated wifi,  rtl871xdrv for Edimax
# we have Edimax EW-7811Un RTL8188CUS
# [    2.935253] usb 1-1.2: New USB device found, idVendor=7392, idProduct=7811
# [    2.938916] usb 1-1.2: Product: 802.11n WLAN Adapter
# [    2.940708] usb 1-1.2: Manufacturer: Realtek
HOSTAPD_DRIVER="rtl871xdrv" #nl80211 rPI3 integrated wifi,  rtl871xdrv for Edimax
# Do:
# http://www.daveconroy.com/turn-your-raspberry-pi-into-a-wifi-hotspot-with-edimax-nano-usb-ew-7811un-rtl8188cus-chipset/
# wget http://www.daveconroy.com/wp3/wp-content/uploads/2013/07/hostapd.zip
# cp /usr/sbin/hostapd /usr/sbin/hostapd.dist && unzip hostapd.zip && mv hostapd /usr/sbin/. && chmod 755 /usr/sbin/hostapd
HOSTAPD_SSID="192.168.6.1"
HOSTAPD_PASSWORD="upandover"

setup () {
    echo "#### Setup Hostapd wifi network"
    command -v dnsmasq || apt-get install dnsmasq
    command -v hostapd || apt-get install hostapd
    killall dnsmasq
    killall hostapd

    # we will start it on our own, as part of the all in one place principle
    sed -i 's/ENABLED=1/ENABLED=0/' /etc/default/dnsmasq
    # NOPE: systemd makes that irrelivant. Do:
    systemctl stop dnsmasq
    rm /etc/systemd/system/multi-user.target.wants/dnsmasq.service  #aka: systemctl disable dnsmasq

    find /etc -name S\*hostapd\* -exec rm {} \;


    if [ ! -f /etc/dnsmasq.conf.dist ]; then
        cp /etc/dnsmasq.conf /etc/dnsmasq.conf.dist
    fi

    cat > /etc/dnsmasq.conf <<EOF
#dhcp-option=option:router,${IP}
dhcp-range=${DHCP_RANGE},255.255.255.0,96h
EOF


    # Setup wifi
    if [ ! -f /etc/network/interfaces.disk ]; then
        cp /etc/network/interfaces /etc/network/interfaces.dist
    fi

    cat > /etc/network/interfaces <<EOF
auto lo
iface lo inet loopback
iface eth0 inet manual
iface wlan0 inet manual
EOF

    systemctl daemon-reload
    systemctl daemon-reload


    cat > /etc/hostapd/hostapd.conf <<EOF
interface=wlan0
driver=${HOSTAPD_DRIVER}
ssid=${HOSTAPD_SSID}
# Use the 2.4GHz band
hw_mode=g
# Use channel 1
channel=1
# Accept all MAC addresses
macaddr_acl=0
# Use WPA authentication
auth_algs=1
# Require clients to know the network name
ignore_broadcast_ssid=0
# Use WPA2
wpa=2
# Use a pre-shared key
wpa_key_mgmt=WPA-PSK
# The network passphrase
wpa_passphrase=${HOSTAPD_PASSWORD}
# Use AES, instead of TKIP
rsn_pairwise=CCMP
EOF

    /etc/init.d/networking reload

}


if [ "$1" == "setup" ]; then
    echo "#### Wifi configuring: $0"
    setup
    echo "#### Wifi configure done"
elif [ "$1" == "start" ]; then
    echo "#### Wifi starting Hostapd"
    LOG="$HOME/network.log"
    killall dnsmasq
    killall hostapd
    killall wpa_supplicant
    #killall dhclient

    echo 1 > /proc/sys/net/ipv4/ip_forward
    iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
    iptables -A FORWARD -i eth0 -o wlan0 -m state --state RELATED,ESTABLISHED -j ACCEPT
    iptables -A FORWARD -i wlan0 -o eth0 -j ACCEPT

    ifconfig wlan0 down
    ifconfig wlan0 up
    sleep 3
    ifconfig wlan0 $IP netmask 255.255.255.0
    sleep 1
    dnsmasq -d -i wlan0 \
      --conf-file="/etc/dnsmasq.conf" \
      --dhcp-leasefile="/var/lib/misc/dnsmasq.leases" \
      --pid-file="/var/run/dnsmasq/dnsmasq.pid" & # &>> "$LOG" &
    sleep 2
    hostapd /etc/hostapd/hostapd.conf -B & # -f "$LOG" &
    echo "#### Wifi startup done"

else
    ## code path reached via interfaces post-up config
    ## called in interfaces post-up
    $0 start
fi
