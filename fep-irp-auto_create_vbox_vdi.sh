#!/bin/sh

#------------------------------------------------------------------------------------------
# This init script (fep-irp-auto_create_vbox_vdi.sh) is released under GNU GPL v2,v3
# Author: Tongguang Zhang
# Date: 2017-05-23
#

#------------------------------------------------------------------------------------------
# copy_vdi() 
# receive three parameter
# num1=$1, the begin number of VM to be created
# num2=$2, the end number of VM to be created
# path=$3, the folder which includes the file lineage-irp-0.vdi
#
# copy lineage-irp-[1-252].vdi from lineage-irp-0.vdi, this process will take a long time.
#
# can copy the files in CLI, such as:
# [root@localhost fep-irp]# /bin/cp lineage-irp-0.vdi lineage-irp-1.vdi; /bin/cp lineage-irp-0.vdi lineage-irp-2.vdi; /bin/cp lineage-irp-0.vdi lineage-irp-3.vdi; /bin/cp lineage-irp-0.vdi lineage-irp-4.vdi; /bin/cp lineage-irp-0.vdi lineage-irp-5.vdi; /bin/cp lineage-irp-0.vdi lineage-irp-6.vdi
#
# [root@localhost fep-irp]# ll -h
# -rw-------. 1 root root 3.6G 4月  24 09:25 lineage-irp-0.vdi
# -rw-------. 1 root root 3.6G 4月  24 09:26 lineage-irp-1.vdi
# -rw-------. 1 root root 3.6G 4月  24 09:26 lineage-irp-2.vdi
# -rw-------. 1 root root 3.6G 4月  24 09:27 lineage-irp-3.vdi
# -rw-------. 1 root root 3.6G 4月  24 09:27 lineage-irp-4.vdi
# -rw-------. 1 root root 3.6G 4月  24 09:27 lineage-irp-5.vdi
# -rw-------. 1 root root 3.6G 4月  24 09:27 lineage-irp-6.vdi
#
#------------------------------------------------------------------------------------------
copy_vdi(){
	num1=$1
	num2=$2
	path=$3

	echo "enter $path"
	cd $path

	for((id=$1; id<=$2; id++))
	do

		vm_name=lineage-irp-$id.vdi
		vm_name_bac=lineage-irp-$id.vdi.bac
		name=lineage-irp-

		# copy lineage-irp-[1-252].vdi from lineage-irp-0.vdi
		# if [ ! -f "$vm_name" ]; then
		if [ -f "$vm_name" ]; then
			echo "$vm_name exists, backup it, then copy $vm_name from lineage-irp-0.vdi"
			#mv $vm_name $vm_name_bac
			rm $vm_name
		fi

		echo "copying $vm_name from lineage-irp-0.vdi"
		cp lineage-irp-0.vdi $vm_name
	done

	echo "exit $path"
	cd -

}
#------------------------------------------------------------------------------------------



#------------------------------------------------------------------------------------------
# create_init() 
# create fep_irp_init_in_lineage.sh
# receive one parameters
#
# adb push ${init_name} /system/xbin/quagga/sbin/fep_irp_init_in_lineage.sh
#------------------------------------------------------------------------------------------
create_init(){

	init_name=fep_irp_init_in_lineage.sh.$1

	eth0_br_ip="112.26.2.$1"

	echo -e "#!/system/bin/sh\n" > $init_name

	# waiting a while, push fep_irp_init_in_lineage.sh in create_vm(),
	# due to that fep_irp_init_in_lineage.sh may be exist in lineage-irp-[1-252].vdi
	# if create lineage-irp-[1-252].vdi from scratch create, then can delete the following line. 
	echo "sleep 60" >> $init_name

#	echo "ifconfig eth0 down" >> $init_name
#	echo "ifconfig eth0 ${eth0_br_ip} netmask 255.255.0.0 up" >> $init_name
	echo "ip address add ${eth0_br_ip}/16 dev eth0" >> $init_name

	echo "mount -o remount,rw /system" >> $init_name
	echo "mount -o remount,rw /" >> $init_name

	echo "mkdir -p /opt/android-on-linux/quagga/out/etc" >> $init_name
	echo "cp /system/xbin/quagga/etc/zebra.conf /opt/android-on-linux/quagga/out/etc/" >> $init_name
	echo "cp /system/xbin/quagga/etc/ospf6d.conf /opt/android-on-linux/quagga/out/etc/" >> $init_name

	echo "sed -i '21a \ router-id 10.1.2.$1' /opt/android-on-linux/quagga/out/etc/ospf6d.conf" >> $init_name

	echo "pkill zebra" >> $init_name
	echo "pkill ospf6d" >> $init_name
	echo "sleep 1" >> $init_name

	echo "/system/xbin/quagga/sbin/zebra -d" >> $init_name
	echo "/system/xbin/quagga/sbin/ospf6d -d" >> $init_name
}
#------------------------------------------------------------------------------------------



#------------------------------------------------------------------------------------------
# NOTE: must be in IBM Server: cd /mnt/vm_img/fep-irp
# [root@localhost fep-irp]# ./fep-irp-auto_create_vbox_vdi.sh 1 6 /mnt/vm_img/fep-irp
# [root@localhost fep-irp]# ./fep-irp-auto_create_vbox_vdi.sh 1 6 /mnt/vm_img/fep-irp
# [root@localhost fep-irp]# ./fep-irp-auto_create_vbox_vdi.sh 1 1 /mnt/vm_img/fep-irp
# [root@localhost fep-irp]# ./fep-irp-auto_create_vbox_vdi.sh 2 2 /mnt/vm_img/fep-irp
# [root@localhost fep-irp]# ./fep-irp-auto_create_vbox_vdi.sh 3 3 /mnt/vm_img/fep-irp
# [root@localhost fep-irp]# ./fep-irp-auto_create_vbox_vdi.sh 4 4 /mnt/vm_img/fep-irp
# [root@localhost fep-irp]# ./fep-irp-auto_create_vbox_vdi.sh 5 5 /mnt/vm_img/fep-irp
# [root@localhost fep-irp]# ./fep-irp-auto_create_vbox_vdi.sh 6 6 /mnt/vm_img/fep-irp
#------------------------------------------------------------------------------------------
# create_vm() 
# receive three parameter
# num1=$1, the begin number of VM to be created
# num2=$2, the end number of VM to be created
# path=$3, the folder which includes the file lineage-irp-0.vdi
#------------------------------------------------------------------------------------------
create_vm(){
	num1=$1
	num2=$2
	path=$3

	# make sure that the first vm get IP 192.168.56.3
	#kill -9 `ps aux|grep vboxnet0|grep -v grep|awk '{print $2}'` &>/dev/null

	echo "enter $path"
	cd $path

	for((id=$1; id<=$2; id++))
	do

		echo "create fep_irp_init_in_lineage.sh"
		create_init $id

		name=lineage-irp-
		init_name=fep_irp_init_in_lineage.sh.${id}

		# make sure that the first vm get IP 192.168.56.3 from vboxnet0_DHCP
		kill -9 `ps aux|grep vboxnet0|grep -v grep|awk '{print $2}'` &>/dev/null
		sleep 1

		VBoxManage createvm --name $name${id} --ostype Linux_64 --register
		VBoxManage modifyvm $name${id} --memory 3072 --vram 128 --usb off --audio pulse --audiocontroller sb16 --acpi on --rtcuseutc off --boot1 disk --boot2 dvd --nic1 hostonly --nictype1 Am79C973 --hostonlyadapter1 vboxnet0 --nic2 none --nic3 none --nic4 none
		VBoxManage storagectl $name${id} --name "IDE Controller" --add ide --controller PIIX4
		VBoxManage internalcommands sethduuid $name${id}.vdi
		VBoxManage storageattach $name${id} --storagectl "IDE Controller" --port 0 --device 0 --type hdd --medium $name${id}.vdi

		# look at VirtualBox Gloable Setting, that is, vboxnet0: 192.168.56.1, 192.168.56.2(DHCPD), (3-254)
		#host0=$[2+id]
		#eth0_vn_ip="192.168.56.${host0}"

		eth0_vn_ip="192.168.56.3"


dbus-launch gnome-terminal -x bash -c "VBoxManage startvm --type headless $name${id}"
sleep 150
dbus-launch gnome-terminal -x bash -c "adb connect ${eth0_vn_ip} && sleep 1 && adb -s ${eth0_vn_ip} root"
sleep 2;
dbus-launch gnome-terminal -x bash -c "adb connect ${eth0_vn_ip} && sleep 1 && adb -s ${eth0_vn_ip} root"
sleep 2;


dbus-launch gnome-terminal -x bash -c "
echo \"adb connect ${eth0_vn_ip}\"; \
adb connect ${eth0_vn_ip} && sleep 1 && adb connect ${eth0_vn_ip} && sleep 1 && adb connect ${eth0_vn_ip} && sleep 1; \
adb -s ${eth0_vn_ip} shell mount -o remount,rw /system; \
adb -s ${eth0_vn_ip} shell mount -o remount,rw /; \
adb push ${init_name} /system/xbin/quagga/sbin/fep_irp_init_in_lineage.sh; \
adb -s ${eth0_vn_ip} shell chmod 755 /system/xbin/quagga/sbin/fep_irp_init_in_lineage.sh; \
echo OK; \
echo \"$name${id} poweroff\"; \
sleep 3"

		# sleep 120
		sleep 20
		VBoxManage controlvm $name${id} poweroff
		sleep 1

	done

	echo "exit $path"
	cd -
}
#------------------------------------------------------------------------------------------




#------------------------------------------------------------------------------------------
# function unregister_vm()
# Description:
# receive two parameters,
# num1=$1, the begin number of VM to be created
# num2=$2, the end number of VM to be created
#
# in IBM Server: /mnt/vm_share/VirtualBoxVMs
# in PC: /root/VirtualBox VMs/
#------------------------------------------------------------------------------------------

unregister_vm(){

	# $1, the begin number of VM to be created
	# $2, the end number of VM to be created

	for((id=$1; id<=$2; id++))
	do
		name=lineage-irp-$id

		VBoxManage controlvm ${name} poweroff &>/dev/null
		VBoxManage unregistervm ${name} &>/dev/null
#		rm "/root/VirtualBox VMs/${name}" -rf &>/dev/null
		rm "/mnt/vm_share/VirtualBoxVMs/${name}" -rf &>/dev/null
		sleep 1
	done
}
#------------------------------------------------------------------------------------------



#------------------------------------------------------------------------------------------
# usage() 
# script usage
# in IBM Server: cd /mnt/vm_img/fep-irp
# [root@localhost fep-irp]# ./fep-irp-auto_create_vbox_vdi.sh 1 6 /mnt/vm_img/fep-irp
#------------------------------------------------------------------------------------------
usage(){
	cat <<-EOU
    Usage: fep-irp-auto_create_vbox_vdi.sh num1 num2 path
        num1, the begin number of VM to be created
        num2, the end number of VM to be created
	path, the folder which includes the file lineage-irp-0.vdi

    For example:
        [root@localhost fep-irp]# pwd
            /mnt/vm_img/fep-irp

        [root@localhost fep-irp]# ls lineage-irp-0.vdi
            lineage-irp-0.vdi

        [root@localhost fep-irp]# ls fep-irp-auto_create_vbox_vdi.sh
            fep-irp-auto_create_vbox_vdi.sh

        ./fep-irp-auto_create_vbox_vdi.sh 1 1 /mnt/vm_img/fep-irp

	EOU
}
#------------------------------------------------------------------------------------------

# num1=$1, the begin number of VM to be created
# num2=$2, the end number of VM to be created
# path=$3, the folder which includes the file lineage-irp-0.vdi

if [ $# -eq 3 ]; then
	if [ ! -f "$3/lineage-irp-0.vdi" ]; then
		echo "please enter correct folder which includes the file lineage-irp-0.vdi"
		exit
	fi

	# copy lineage-irp-[1-252].vdi from lineage-irp-0.vdi
	# this process will take a long time.
	# Need to pay attention
	# copy_vdi $1 $2 $3

	unregister_vm $1 $2
	#unregister_vm $1 $2

	create_vm $1 $2 $3
else
	usage
fi

# [root@localhost fep-irp]# pwd
# /opt/share-vm/fedora23server-share

# it is safe to execute the following command (./fep-irp-auto-run-vbox-and-docker.sh destroy 0 1) twice.

# [root@localhost fep-irp]# ./fep-irp-auto-run-vbox-and-docker.sh destroy 0 1 centos-manet lineage-irp- /mnt/vm_img/fep-irp

# [root@localhost fep-irp]# ./fep-irp-auto-run-vbox-and-docker.sh destroy 0 1 centos-manet lineage-irp- /mnt/vm_img/fep-irp

# [root@localhost fep-irp]# ./fep-irp-auto_create_vbox_vdi.sh 1 1 /mnt/vm_img/fep-irp

# [root@localhost fep-irp]# ./fep-irp-auto-run-vbox-and-docker.sh destroy 0 5 centos-manet lineage-irp- /mnt/vm_img/fep-irp

# [root@localhost fep-irp]# ./fep-irp-auto_create_vbox_vdi.sh 1 6 /mnt/vm_img/fep-irp

