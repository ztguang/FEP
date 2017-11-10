#!/bin/sh

# Testing a simple Information Release Platform for Disaster Relief in FEP.
#
# This tool (fep-irp-auto-run-vbox-and-docker.sh) is released under GNU GPL v2,v3
# Author: Tongguang Zhang
# Date: 2017-05-23
#

#------------------------------------------------------------------------------------------
# function create_docker()
# Description:
# create $docker_node_num of dockers
# receive two parameters, that are docker_node_num, docker_image
#
#
# docker: 112.26.[1-254].[1-255]
# lineage: 112.26.255.[1-254]
#
# //IP address scope: 112.26.1.${id}/16
# IP address scope: 112.26.${seg2}.${seg1}/16
# seg1 = [1-255]
# seg2 = [1-254]
#------------------------------------------------------------------------------------------

create_docker(){

	# $1, that is, docker_node_num
	# $2, that is, docker_image

	if [ ! -d /proc/sys/net/bridge ]; then
		modprobe br_netfilter
	fi

	cd /proc/sys/net/bridge
	for f in bridge-nf-*; do echo 0 > $f; done
	cd -

	rm /var/run/netns -rf &>/dev/null
	mkdir -p /var/run/netns &>/dev/null

	# $1, that is, docker_node_num
	# $2, that is, docker_image

	for((id=1; id<=$1; id++))
	do
		# docker: 112.26.[1-254].[1-255]
		# docker: 112.26.${seg2}.${seg1}/16
		seg1=`expr ${id} % 255`
		if [ $seg1 -eq 0 ]; then
			seg1=255
		fi
		seg2=`expr \( ${id} - 1 \) / 255 + 1`

		# to determine whether docker_image exists
		vm_image="$2"
		exists=`docker images | awk -F \" '{print $1}' | grep ${vm_image} | wc -l | cat`
		if [ $exists -eq 0 ]; then
			echo "${vm_image} does not exist"
			exit
		fi

	dbus-launch gnome-terminal -x bash -c "docker run --privileged -it -d --net='none' --name \"docker_${id}\" $2"
	# if number of nodes is larger, then increase the secondes for sleep, otherwise pid=0
	if [ $id -gt 0 ] && [ $id -lt 11 ]; then
		sleep 3
	elif [ $id -gt 10 ] && [ $id -lt 21 ]; then
		sleep 5
	elif [ $id -gt 20 ] && [ $id -lt 31 ]; then
		sleep 7
	elif [ $id -gt 30 ] && [ $id -lt 41 ]; then
		sleep 9
	elif [ $id -gt 40 ] && [ $id -lt 51 ]; then
		sleep 11
	elif [ $id -gt 50 ] && [ $id -lt 61 ]; then
		sleep 13
	elif [ $id -gt 60 ] && [ $id -lt 71 ]; then
		sleep 15
	elif [ $id -gt 70 ] && [ $id -lt 81 ]; then
		sleep 17
	else
		sleep 19
	fi

	docker exec docker_${id} /bin/sh -c "sed -i '21a \ router-id 10.1.${seg2}.${seg1}' /usr/local/etc/ospf6d.conf"
	docker exec docker_${id} /bin/sh -c "zebra -d &>/dev/null"
	docker exec docker_${id} /bin/sh -c "ospf6d -d &>/dev/null"

		# SET VARIABLES

		# get PID of CONTAINER
		pid=$(docker inspect -f '{{.State.Pid}}' "docker_${id}")

		bridge="br_d_${id}"
		tap="tap_d_${id}"
		veth="veth_${id}"
		deth="deth_${id}"

		brctl addbr ${bridge}

		ip link add ${veth} type veth peer name ${deth}
		brctl addif ${bridge} ${veth}
		ip link set ${veth} up

		ip link set ${deth} netns ${pid}

		tunctl -t ${tap}
		ifconfig ${tap} up

		brctl addif ${bridge} ${tap}
		ifconfig ${bridge} up

		ln -s /proc/${pid}/ns/net /var/run/netns/${pid}

		ip netns exec ${pid} ip link set dev ${deth} name eth0
		ip netns exec ${pid} ip link set eth0 up
		ip netns exec ${pid} ip addr add 112.26.${seg2}.${seg1}/16 dev eth0
	done
}

#------------------------------------------------------------------------------------------
# function destroy_docker()
# Description:
# destroy $docker_node_num of dockers
# receive one parameter, that is docker_node_num
#------------------------------------------------------------------------------------------

destroy_docker(){

	# $1, that is, $docker_node_num
	for((id=1; id<=$1; id++))
	do
		bridge="br_d_${id}"
		tap="tap_d_${id}"
		veth="veth_${id}"

		ifconfig ${bridge} down &>/dev/null
		brctl delif ${bridge} ${tap} &>/dev/null
		brctl delbr ${bridge} &>/dev/null

		ifconfig ${tap} down &>/dev/null
		tunctl -d ${tap} &>/dev/null
		ifconfig ${veth} down &>/dev/null

		docker stop "docker_${id}" &>/dev/null
		docker rm "docker_${id}" &>/dev/null
	done
}



#------------------------------------------------------------------------------------------
# function create_android()
# Description:
# create $android_node_num of dockers
# receive three parameters, that are docker_node_num, android_node_num, VM_image
#
# docker: 112.26.[1-254].[1-255]
# lineage: 112.26.255.[1-254]
#
# //IP address scope: 112.26.2.${id}/16
# IP address scope: 112.26.255.${id}/16
# id = [1-254]
#------------------------------------------------------------------------------------------

create_android(){	

	# $1, that is, docker_node_num
	# $2, that is, android_node_num
	# $3, that is, VM_image
	# $4, that is, PATH of *.vdi

	if [ ! -d /proc/sys/net/bridge ]; then
		modprobe br_netfilter
	fi

	cd /proc/sys/net/bridge
	for f in bridge-nf-*; do echo 0 > $f; done
	cd -

	for((id=1; id<=$2; id++))
	do

		# SET VARIABLES
		bridge="br_a_${id}"
		tap="tap_a_${id}"

		tunctl -t ${tap}
		ifconfig ${tap} up
		brctl addbr ${bridge}
		brctl addif ${bridge} ${tap}
		ifconfig ${bridge} up

		echo "VBoxManage startvm $3${id}"

		dbus-launch gnome-terminal -x bash -c "VBoxManage createvm --name $3${id} --ostype Linux_64 --register; \
VBoxManage modifyvm $3${id} --memory 3072 --vram 128 --usb off --audio pulse --audiocontroller sb16 --acpi on --rtcuseutc off --boot1 disk --boot2 dvd --nic1 bridged --nictype1 Am79C973 --bridgeadapter1 ${bridge} --nic2 none --nic3 none --nic4 none; \
VBoxManage storagectl $3${id} --name \"IDE Controller\" --add ide --controller PIIX4; \
VBoxManage internalcommands sethduuid $4/$3${id}.vdi; \
VBoxManage storageattach $3${id} --storagectl \"IDE Controller\" --port 0 --device 0 --type hdd --medium $4/$3${id}.vdi; \
VBoxManage startvm $3${id}; \
sleep 100"

		sleep 3
	done
}


#------------------------------------------------------------------------------------------
# function destroy_android()
# Description:
# destroy $android_node_num of androids
# receive two parameters, that are android_node_num, VM_image
#
# in IBM Server: /mnt/vm_share/VirtualBoxVMs
# in PC: /root/VirtualBox VMs/
#------------------------------------------------------------------------------------------

destroy_android(){

	# $1, that is, $android_node_num
	# $2, that is, VM_image

	for((id=1; id<=$1; id++))
	do
		echo "VBoxManage controlvm $2${id} poweroff"

		VBoxManage controlvm $2${id} poweroff &>/dev/null
		VBoxManage unregistervm $2${id} &>/dev/null
		rm "/mnt/vm_share/VirtualBoxVMs/$2${id}" -rf &>/dev/null
		sleep 1

		bridge="br_a_${id}"
		tap="tap_a_${id}"

		ifconfig ${bridge} down &>/dev/null
		brctl delif ${bridge} ${tap} &>/dev/null
		brctl delbr ${bridge} &>/dev/null

		ifconfig ${tap} down &>/dev/null
		tunctl -d ${tap} &>/dev/null
	done
}


#------------------------------------------------------------------------------------------
# usage() 
# script usage
#------------------------------------------------------------------------------------------
usage(){
	cat <<-EOU
    Usage: fep-irp-auto-run-vbox-and-docker.sh a b c d e f
        a, the value is create or destroy
        b, the number of dockers to be created
        c, the number of androids to be created
        d, docker image, such as, busybox or ubuntu, etc.
        e, Android image, such as, lineage-irp-
        f, the path of Android image, such as, /opt/virtualbox-os/

        Note: b + c <= 254

    For example:
        [root@localhost fep-irp]# pwd
            /mnt/vm_img/fep-irp
        [root@localhost fep-irp]# ls fep-irp-auto-run-vbox-and-docker.sh
            fep-irp-auto-run-vbox-and-docker.sh
        [root@localhost fep-irp]#

        ./fep-irp-auto-run-vbox-and-docker.sh create 30 0 centos-fep-irp lineage-irp-  PATH_of_*.vdi
        ./fep-irp-auto-run-vbox-and-docker.sh destroy 30 0 centos-fep-irp lineage-irp-  PATH_of_*.vdi

        ./fep-irp-auto-run-vbox-and-docker.sh create 0 6 centos-fep-irp lineage-irp-  PATH_of_*.vdi
        ./fep-irp-auto-run-vbox-and-docker.sh destroy 0 6 centos-fep-irp lineage-irp-  PATH_of_*.vdi

        ./fep-irp-auto-run-vbox-and-docker.sh create 30 6 centos-fep-irp lineage-irp-  PATH_of_*.vdi
        ./fep-irp-auto-run-vbox-and-docker.sh destroy 30 6 centos-fep-irp lineage-irp-  PATH_of_*.vdi

	EOU
}


#------------------------------------------------------------------------------------------
# function create_ns3_manet_seem_cc()
# receive two parameter, that is docker_node_num, android_node_num
#------------------------------------------------------------------------------------------

create_ns3_manet_seem_cc(){
	echo "create fep-irp-manet.cc from fep-irp-manet-template.cc"

	cd /opt/tools/network_simulators/ns3/ns-allinone-3.25/ns-3.25/scratch
	rm fep-irp-manet.cc -f &>/dev/null
	cp fep-irp-manet-template.cc fep-irp-manet.cc

	str='255a \\n  '

	for((id=1; id<=$1; id++))
	do
		tap="tap_d_${id}"
		ns=$[id-1]
		inter="tapBridge.SetAttribute (\"DeviceName\", StringValue (\"${tap}\"));\n  tapBridge.Install (adhocNodes.Get (${ns}), adhocDevices.Get (${ns}));\n  "
		str=${str}${inter}
	done

	for((ns=$1, id=1; id<=$2; id++, ns++))
	do
		tap="tap_a_${id}"
		inter="tapBridge.SetAttribute (\"DeviceName\", StringValue (\"${tap}\"));\n  tapBridge.Install (adhocNodes.Get (${ns}), adhocDevices.Get (${ns}));\n  "

		str=${str}${inter}
	done

	sed -i "${str}" fep-irp-manet.cc

	cd -
}


#------------------------------------------------------------------------------------------
# function start_ns3()
#------------------------------------------------------------------------------------------

start_ns3(){
	echo "RUNNING SIMULATION, press CTRL-C to stop it"

	cd /opt/tools/network_simulators/ns3/ns-allinone-3.25/ns-3.25

	./waf --run scratch/fep-irp-manet --vis &

	cd -
}


#------------------------------------------------------------------------------------------
# ./fep-irp-auto-run-vbox-and-docker.sh para1 para2 para3 para4 para5 para6
# para1 ($1), that is, the value is create or destroy
# para2 ($2), that is, the number of dockers to be created
# para3 ($3), that is, the number of androids to be created
# para4 ($4), that is, docker image, such as, busybox or ubuntu, etc.
# para5 ($5), that is, Android image, such as, lineage-irp-
# para6 ($6), that is, the path of Android image, such as, /opt/virtualbox-os/
# [root@localhost fep-irp]# pwd
# /mnt/vm_img/fep-irp
# [root@localhost fep-irp]# ls
# lineage-irp-1.vdi  lineage-irp-2.vdi  lineage-irp-3.vdi  lineage-irp-4.vdi  lineage-irp-5.vdi  lineage-irp-6.vdi
# 
# ./fep-irp-auto-run-vbox-and-docker.sh create 36 0 centos-fep-irp lineage-irp-  PATH_of_*.vdi
# ./fep-irp-auto-run-vbox-and-docker.sh destroy 36 0 centos-fep-irp lineage-irp-  PATH_of_*.vdi
# 
# ./fep-irp-auto-run-vbox-and-docker.sh create 0 6 centos-fep-irp lineage-irp-  PATH_of_*.vdi
# ./fep-irp-auto-run-vbox-and-docker.sh destroy 0 6 centos-fep-irp lineage-irp-  PATH_of_*.vdi
# 
# ./fep-irp-auto-run-vbox-and-docker.sh create 30 6 centos-fep-irp lineage-irp-  PATH_of_*.vdi
# ./fep-irp-auto-run-vbox-and-docker.sh destroy 30 6 centos-fep-irp lineage-irp-  PATH_of_*.vdi
#------------------------------------------------------------------------------------------

# docker search image_name
# docker pull image_name
# docker images
# docker rmi image_name
# docker run --privileged -i -t -d --net=none --name docker_$id $docker_image -t $type -i $id
# docker ps

# systemctl start docker.service

# the number of dockers and androids should be less than 254,
# if you have more nodes in your emulation environment, you can modify corresponding code.

a=$2
b=$3

if [ $# -eq 6 ]; then

	if [ $[a+0] -gt 64770 ] || [ $[0+b] -gt 254 ] || [ $2 -lt 0 ] || [ $3 -lt 0 ] || !([ $1 == "create" ]||[ $1 == "destroy" ]); then
		usage
		exit
	fi

	case $1 in
		create)
			if [ $2 -gt 0 ]; then create_docker $2 $4; fi
			if [ $3 -gt 0 ]; then create_android $2 $3 $5 $6; fi
			if [ $[a+b] -gt 0 ]; then
				create_ns3_manet_seem_cc $2 $3

			# ./fep-irp-manet-creat-ns3-script.sh 030 6
			# ./fep-irp-manet-creat-ns3-script.sh 025 0
			# ./fep-irp-manet-creat-ns3-script.sh 100 0
			# ./fep-irp-manet-creat-ns3-script.sh 225 0
			# ./fep-irp-manet-creat-ns3-script.sh 400 0
			# ./fep-irp-manet-creat-ns3-script.sh 625 0
		;;
		destroy)
			if [ $2 -gt 0 ]; then
				destroy_docker $2
				rm /var/run/netns -rf &>/dev/null
			fi

			if [ $3 -gt 0 ]; then
				destroy_android $3 $5
				ifconfig vboxnet0 down &>/dev/null
			fi
		;;
	esac
else
	usage
fi

# [root@localhost fep-irp]# pwd
# /mnt/vm_img/fep-irp
# [root@localhost fep-irp]# ls
# lineage-irp-0.vdi  lineage-irp-2.vdi  lineage-irp-4.vdi  lineage-irp-6.vdi
# lineage-irp-1.vdi  lineage-irp-3.vdi  lineage-irp-5.vdi
# [root@localhost fep-irp]# 



#-----------------------------------------------------------------------------
# 36 docker (centos)
#-----------------------------------------------------------------------------
# systemctl start docker.service
# systemctl status docker.service

# [root@localhost fep-irp]# pwd
# /mnt/vm_img/fep-irp

# ./fep-irp-auto-run-vbox-and-docker.sh create 36 0 centos-fep-irp lineage-irp- /mnt/vm_img/fep-irp

# ./fep-irp-auto-run-vbox-and-docker.sh destroy 36 0 centos-fep-irp lineage-irp- /mnt/vm_img/fep-irp

# cd /opt/tools/network_simulators/ns3/ns-allinone-3.25/ns-3.25
# ./waf --run scratch/fep-irp-manet --vis
# ./waf --run scratch/fep-irp-manet-36-docker --vis
# ./waf --run scratch/fep-irp-manet-6-docker --vis
#
# [root@localhost tmp]# tcpdump -vv -n -i br_d_1
#
# docker run --privileged -it -d --name "docker_1" centos-fep-irp
# docker ps -a
# docker attach docker_1
# docker stop docker_1
# docker start docker_1
# docker rm docker_1

# docker ps
# docker rmi 2c067614b89f

# [root@localhost tmp]# tcpdump -i veth_1 > veth_1.txt
# [root@localhost tmp]# gedit veth_1.txt



#-----------------------------------------------------------------------------
# 6 lineage
#-----------------------------------------------------------------------------
#
# [root@localhost fep-irp]# pwd
# /mnt/vm_img/fep-irp

# ./fep-irp-auto-run-vbox-and-docker.sh create 0 6 centos-fep-irp lineage-irp- /mnt/vm_img/fep-irp
#
# ./fep-irp-auto-run-vbox-and-docker.sh destroy 0 6 centos-fep-irp lineage-irp- /mnt/vm_img/fep-irp
#
# cd /opt/tools/network_simulators/ns3/ns-allinone-3.25/ns-3.25
# ./waf --run scratch/fep-irp-manet --vis
# ./waf --run scratch/fep-irp-manet-6-lineage --vis

#-----------------------------------------------------------------------------
# 30 docker (centos) and 6 lineage, automatically.
#-----------------------------------------------------------------------------
#
# [root@localhost fep-irp]# pwd
# /mnt/vm_img/fep-irp

# ./fep-irp-auto-run-vbox-and-docker.sh create 30 6 centos-fep-irp lineage-irp- /mnt/vm_img/fep-irp
#
# ./fep-irp-auto-run-vbox-and-docker.sh destroy 30 6 centos-fep-irp lineage-irp- /mnt/vm_img/fep-irp

#-----------------------------------------------------------------------------

#
# busybox route add -host 112.26.2.1 dev eth0
# busybox route add -host 112.26.2.1 gw 112.26.2.254

# [root@localhost tmp]# pwd
# /root/tmp
# [root@localhost tmp]# ls
# nictracefile_1  nictracefile_2  nictracefile_3  nictracefile_4  nictracefile_5  t.txt
# [root@localhost tmp]# tcpdump -r nictracefile_1
# [root@localhost tmp]# tcpdump -r nictracefile_1 > nictracefile_1.txt
# [root@localhost tmp]# gedit nictracefile_1.txt

# [root@localhost tmp]# tcpdump -i vboxnet0 > vboxnet0.txt
# [root@localhost tmp]# tcpdump -i vboxnet0 ip6 > vboxnet0.txt
# [root@localhost tmp]# tcpdump -i br_a_1 > br_a_1.txt
# [root@localhost tmp]# tcpdump -i br_a_2 ip6 > br_a_2.txt
# [root@localhost tmp]# tcpdump -ne -i br_a_2 ip6 > br_a_2.txt

# [root@localhost tmp]# tcpdump -vv -n -i br_a_1

# have you enabled IPv6 on the interface at all? if the bridge device is br_a_1, then do this:
# sysctl net.ipv6.conf.br_a_1.disable_ipv6=0
# sysctl net.ipv6.conf.br_a_1.autoconf=1
# sysctl net.ipv6.conf.br_a_1.accept_ra=1
# sysctl net.ipv6.conf.br_a_1.accept_ra_defrtr=1
# less /proc/sys/net/ipv6/conf/br_a_1/disable_ipv6

# Every IPv6 address, even link-local ones, automatically subscribe to a multicast group based on its last 24 bits. If multicast snooping is enabled, the bridge filters out (almost) all multicast traffic by default. When an IPv6 address is assigned to an interface, the system must inform the network that this interface is interested in that particular multicast group and must be excluded by the filter. The following is a good introductory video: https://www.youtube.com/watch?v=O1JMdjnn0ao
# Multicast snooping is there to prevent flooding the network with multicast packets that most systems aren't interested. You can disable multicast snooping in small deployments without noticing any big difference. But this may have significant performance impact on larger deployments.   You can disable snooping with:
# echo -n 0 > /sys/class/net/br_a_1/bridge/multicast_snooping
# echo -n 0 > /sys/class/net/br_a_2/bridge/multicast_snooping
# echo -n 0 > /sys/class/net/br_a_3/bridge/multicast_snooping
# echo -n 0 > /sys/class/net/br_a_4/bridge/multicast_snooping
# echo -n 0 > /sys/class/net/br_a_5/bridge/multicast_snooping

# If you want to protect your VMs from unwanted traffic and unnecessary packet processing, you can leave snooping enabled but also enable a multicast Querier on the network. A Querier will periodically broadcast query packets and update snooping filters on switches and bridges. It is possible to enable a Querier on your system with:
# echo -n 1 > /sys/class/net/br_a_1/bridge/multicast_querier
# echo -n 1 > /sys/class/net/br_a_2/bridge/multicast_querier
# echo -n 1 > /sys/class/net/br_a_3/bridge/multicast_querier
# echo -n 1 > /sys/class/net/br_a_4/bridge/multicast_querier
# echo -n 1 > /sys/class/net/br_a_5/bridge/multicast_querier

# ip -6 nei
# ip -4 neighbor

# setprop service.adb.tcp.port 5555
# stop adbd
# start adbd

# cd /mnt/vm_img/fep-irp

#------------------------------------------------------------------------------------------
# So far, All is OK
#------------------------------------------------------------------------------------------

