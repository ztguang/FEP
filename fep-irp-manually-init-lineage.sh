#!/bin/sh

#------------------------------------------------------------------------------------------
# This init script (fep-irp-manually-init-lineage.sh) is released under GNU GPL v2,v3
# Author: Tongguang Zhang
# Date: 2017-05-23
# 
# copy quagga to /system/xbin/quagga, refer to http://blog.csdn.net/ztguang/article/details/51768680
# that is: fep-irp-install_quagga_on_android_7_in_Fedora24.txt
# 

#------------------------------------------------------------------------------------------
adb connect 192.168.56.3 && adb -s 192.168.56.3 root
sleep 1
adb connect 192.168.56.3 && adb -s 192.168.56.3 root
adb connect 192.168.56.3

adb shell mount -o remount,rw /system
adb shell mount -o remount,rw /

adb shell mkdir -p /system/xbin/quagga/etc

#----------------------------------------------------------------
cd /opt/android-x86/tmp-iso-can-del/fep-lib-exe/
adb push zebra.conf /system/xbin/quagga/etc/
adb push ospf6d.conf /system/xbin/quagga/etc/
adb push sbin/ /system/xbin/quagga/
adb push libzebra.so /system/lib64/
adb push libospf.so /system/lib64/
adb push libospfapiclient.so /system/lib64/
adb push libstlport_shared.so /system/lib64/
adb push libc++_shared.so /system/lib64/
adb push busybox-x86_64 /system/xbin/
# curl
adb push curl /system/xbin/
adb push libcurl.so /system/lib64/
# mongoose
adb push webserver/ /system/xbin/quagga/
cd -
#----------------------------------------------------------------

