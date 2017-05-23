#
# This manual is released under GNU GPL v2,v3
# Author: Tongguang Zhang
# Date: 2017-05-23
#

========================================================= fep testing - begin - use
in IBM Server
----------------------------------------------------
dnf update
dnf remove docker
dnf install docker
dnf update
init 6
----------------------------------------------------


----------------------------------------------------
install docker
---------------------------------------------------- use

//dnf update --exclude=kernel*

dnf update

dnf remove docker

dnf install docker
dnf install docker-io
dnf install docker-engine


rm /var/lib/docker/ -rf
ls /var/lib/docker/

systemctl start docker
systemctl stop docker
systemctl status docker
systemctl enable docker

docker search busybox
docker pull busybox
docker images
docker tag 307ac631f1b5 docker.io/busybox:core
docker rmi docker.io/busybox:core

docker run --rm -it busybox /bin/sh

dnf remove docker-io
rm /var/lib/docker/ -rf
----------------------------------------------------
So far, OK
----------------------------------------------------

----------------------------------------------------------------------------------------
install docker-centos-quagga-ospf-mdr
----------------------------------------------------------------------------------------
docker search centos
docker pull centos
docker images

docker run --privileged -it --rm centos /bin/bash

[root@52ded645306a quagga]# cat /etc/redhat-release
CentOS Linux release 7.3.1611 (Core)

[root@c429860ee03f /]# 

yum install nmap-ncat gcc gcc-c++ make autoconf automake ccache tar libtool readline-devel texinfo net-tools less which vim tcpdump

----------------------------------------------------------------------------------------
www.nrl.navy.mil —— OSPF MANET Designated Routers (OSPF-MDR) Implementation 
----------------------------------------------------------------------------------------

----------------------------------------------
in PC
----------------------------------------------
[root@localhost fep]# find /opt/tools/network_simulators/ -name quagga-svnsnap*
/opt/tools/network_simulators/core-nrl-navy-mil/quagga-svnsnap.tgz
/opt/tools/network_simulators/quagga/quagga-svnsnap.tgz

[root@localhost fep]# pwd
/opt/share-vm/fedora23server-share/fep
[root@localhost fep]# 

wget http://downloads.pf.itd.nrl.navy.mil/ospf-manet/nightly_snapshots/quagga-svnsnap.tgz

scp /opt/share-vm/fedora23server-share/fep/quagga-svnsnap.tgz 10.109.253.80:/mnt/vm_img/fep-irp
scp /opt/share-vm/fedora23server-share/fep/quagga-svnsnap-2017-04-20.tgz 10.109.253.80:/mnt/vm_img/fep-irp
----------------------------------------------
in IBM Server
----------------------------------------------
(Host)
[root@localhost fep-irp]# cd /mnt/vm_img/fep-irp

nc -l 12123 < quagga-svnsnap-2017-04-20.tgz

(Docker)
[root@a9135687be7c /]# nc -n 172.17.0.1 12123 > quagga-svnsnap-2017-04-20.tgz

【 Ctrl + C 】

[root@a9135687be7c /]# tar -xzf quagga-svnsnap-2017-04-20.tgz
----------------------------------------------------------------------------------------
[root@a9135687be7c /]# ls
quagga  quagga-mtr  quagga-svnsnap-2017-04-20.tgz  ...

[root@a9135687be7c /]# cd quagga
[root@a9135687be7c quagga]# pwd
/quagga

// [root@a9135687be7c quagga]# ./update-autotools
// [root@a9135687be7c quagga]# aclocal -I m4 --install

[root@a9135687be7c quagga]# 

./bootstrap.sh
./configure --enable-user=root --enable-group=root --enable-vtysh --with-cflags=-ggdb

----------------------------------------------------------------------------------------
Quagga configuration
--------------------
quagga version          : 0.99.21mr2.2-dev
host operating system   : linux-gnu
source code location    : .
compiler                : gcc
compiler flags          : -ggdb
C++ compiler            : g++
C++ compiler flags      : -ggdb
make                    : make
includes                :  
linker flags            :  -lcrypt   -lrt   -ltermcap -lreadline -lm
state file directory    : /var/run
config file directory   : /usr/local/etc
example directory       : /usr/local/etc
user to run as		: root
group to run as		: root
group for vty sockets	: 
config file mask        : 0600
log file mask           : 0600
generic netlink         : no
  (support for RFC 4938 link metrics)
----------------------------------------------------------------------------------------
make
make install

cd /usr/local/etc/
cp ospf6d.conf.sample ospf6d.conf
cp zebra.conf.sample zebra.conf

[root@a9135687be7c etc]# zebra -d
[root@a9135687be7c etc]# ospf6d -d
WARNING: ack interval should not exceed one second
[root@a9135687be7c etc]# vtysh
> show ipv6 ospf6 route
> show ip route
> show ipv6 route
> exit

route add 123.123.123.123 reject
route -n
route del 123.123.123.123 reject


(Host)

// Saving the Image
docker ps -a
docker commit a9135687be7c centos-fep-irp
docker images

[root@localhost fep-irp]# docker images
REPOSITORY          TAG                 IMAGE ID            CREATED             SIZE
centos-fep-irp      latest              6d7988b95ede        31 seconds ago      553.9 MB
docker.io/centos    latest              a8493f5f50ff        2 weeks ago         192.5 MB
[root@localhost fep-irp]# 

(Docker)

[root@a9135687be7c etc]# exit

----------------------------------------------------------------------------------------

docker run --privileged -it --rm centos-fep-irp /bin/bash
docker run --privileged -it --rm --name "docker_1" centos-fep-irp /bin/bash
docker run --privileged -it --rm --net='none' --name "docker_1" centos-fep-irp /bin/bash

-------------------------------------------------
docker run --privileged -it -d --name "docker_1" centos-fep-irp
docker ps -a
docker attach docker_1
docker stop docker_1
docker start docker_1
docker rm docker_1
-------------------------------------------------

docker ps
docker rmi 2c067614b89f
----------------------------------------------------------------------------------------


========================================================= fep testing - end - use



# ============================================================= 打开调试功能 - begin
-------------------------------------------------
gedit lib/log.c
-------------------------------------------------
static void
vzlog (struct zlog *zl, int priority, const char *format, va_list args)
{
  /* File output. */
//  if ((priority <= zl->maxlvl[ZLOG_DEST_FILE]) && zl->fp)
  if (zl->fp)
}
-------------------------------------------------

-------------------------------------------------
gedit zebra/main.c ospf6d/ospf6_main.c ospfd/ospf_main.c xpimd/zebra_router.cc
-------------------------------------------------
int
main (int argc, char **argv)
{
  FILE *fp;
  const char *filename = "/opt/android-on-linux/quagga/out/run/quagga-log.txt";
  fp = fopen (filename, "a");
									// 在 main 开始处添加上面 3 行
  zlog_default = openzlog (progname, ZLOG_ZEBRA,			// 在 该行 下面 添加下面 3 行
			   LOG_CONS|LOG_NDELAY|LOG_PID, LOG_DAEMON);

  /* Set flags. */
  zlog_default->filename = strdup (filename);
  zlog_default->fp = fp;
}
-------------------------------------------------

-------------------------------------------------
gedit ospf6d/ospf6_message.c
-------------------------------------------------
void
// Send in length because TLV might be longer than OSPF header length
ospf6_send (struct in6_addr *src, struct in6_addr *dst,
            struct ospf6_interface *oi, struct ospf6_header *oh, int length)
{
  /* Log */
  //if (IS_OSPF6_DEBUG_MESSAGE (oh->type, SEND))		// ztg alter
  if (1)
  {
		// 这里输出大量的 OSPF6 包信息
  }
  /* send message */
  len = ospf6_sendmsg (src, dst, &oi->interface->ifindex, iovector);			// 调用 ospf6_sendmsg
  if (len != length)
    zlog_err ("Could not send entire message length %d != %d", length, len);
}
-------------------------------------------------

-------------------------------------------------
gedit ospf6d/ospf6_network.c
-------------------------------------------------
int
ospf6_sendmsg (struct in6_addr *src, struct in6_addr *dst,
               unsigned int *ifindex, struct iovec *message)
{
  retval = sendmsg (ospf6_sock, &smsghdr, 0);
  zlog_warn ("sendmsg: ifindex(%d)", *ifindex);			// ztg add
  if (retval != iov_totallen (message))
    zlog_warn ("sendmsg failed: ifindex: %d: %s (%d)",
               *ifindex, safe_strerror (errno), errno);

  return retval;
}
-------------------------------------------------

# ============================================================= 打开调试功能 - end


### 下面，打包、上传到 docker，测试，查看 路由表的更新流程

[root@ztg android-on-linux]# rm quagga-4-docker.tgz
[root@ztg android-on-linux]# tar -czf quagga-4-docker.tgz quagga-4-docker/

scp /opt/android-on-linux/quagga-4-docker.tgz 10.109.253.80:/mnt/vm_img/fep-irp

--------------------------------
in IBM Server
--------------------------------
(Host)
[root@localhost fep-irp]# cd /mnt/vm_img/fep-irp

nc -l 12123 < quagga-4-docker.tgz

(Docker)
docker run --privileged -it --rm --name "docker_1" centos-fep-irp /bin/bash

[root@a9135687be7c /]# cd quagga

[root@a9135687be7c quagga]# make uninstall
[root@a9135687be7c quagga]# make clean
[root@a9135687be7c quagga]# cd /

[root@ffb4568ff691 /]# rm quagga -rf
[root@ffb4568ff691 /]# rm quagga-4-docker.tgz -f
[root@a9135687be7c /]# nc -n 172.17.0.1 12123 > quagga-4-docker.tgz

【 Ctrl + C 】

[root@a9135687be7c /]# tar -xzf quagga-4-docker.tgz
[root@a9135687be7c /]# mv quagga-4-docker quagga
[root@a9135687be7c /]# cd quagga
[root@a9135687be7c quagga]# 

./bootstrap.sh
./configure --enable-user=root --enable-group=root --enable-vtysh --with-cflags=-ggdb

----------------------------------
Quagga configuration
--------------------
quagga version          : 0.99.21mr2.2-dev
host operating system   : linux-gnu
linker flags            :  -lcrypt   -lrt   -ltermcap -lreadline -lm
state file directory    : /var/run
config file directory   : /usr/local/etc
example directory       : /usr/local/etc
user to run as		: root
group to run as		: root
----------------------------------


make
make install

mkdir -p /opt/android-on-linux/quagga/out/run/
touch /opt/android-on-linux/quagga/out/run/quagga-log.txt

cd /usr/local/etc/
cp ospf6d.conf.sample ospf6d.conf
cp zebra.conf.sample zebra.conf


--------------------------------
// Saving the Image
--------------------------------
docker ps -a
docker commit 3b388df6de71 centos-fep-irp
docker images
--------------------------------




