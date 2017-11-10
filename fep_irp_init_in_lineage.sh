#!/system/bin/sh
# This init script (fep-irp-init-in-lineage.sh) is released under GNU GPL v2,v3
# Author: Tongguang Zhang
# Date: 2017-05-23
# 

if [ ! -f /opt/init.txt ]; then

	mount -o remount,rw /system
	mount -o remount,rw /
	mkdir -p /opt/android-on-linux/quagga/out/etc
	mkdir -p /opt/android-on-linux/quagga/out/run
	cp /system/xbin/quagga/etc/zebra.conf /opt/android-on-linux/quagga/out/etc/
	cp /system/xbin/quagga/etc/ospf6d.conf /opt/android-on-linux/quagga/out/etc/
	sed -i '21a \ router-id 10.1.255.1' /opt/android-on-linux/quagga/out/etc/ospf6d.conf

	touch /opt/init.txt
fi

	ifconfig eth0 down
	ifconfig eth0 112.26.255.1 netmask 255.255.0.0 up
	ip addr add 112.26.255.1/16 dev eth0

	echo 1 > /proc/sys/net/ipv4/ip_forward	   

	iptables -F

