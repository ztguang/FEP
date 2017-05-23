#!/system/bin/sh
# This init script is released under GNU GPL v2,v3
# Author: Tongguang Zhang
# Date: 2017-05-23
#

================================================ 30 docker, 6 lineage

# (Android 7)
./fep-irp-auto-run-vbox-and-docker.sh create 30 6 centos-fep-irp lineage-irp- /mnt/vm_img/fep-irp-nougat
./fep-irp-auto-run-vbox-and-docker.sh destroy 30 6 centos-fep-irp lineage-irp- /mnt/vm_img/fep-irp-nougat

# NS3:
#	cd /opt/tools/network_simulators/ns3/ns-allinone-3.26/ns-3.26
#	./waf --run scratch/fep-irp-manet --vis &

================================================ mongoose simplest_web_server

# exec the below 3 commands one by one
cd /system/xbin/quagga/webserver/
/system/xbin/quagga/webserver/simplest_web_server &>/dev/null &
/system/xbin/quagga/webserver/websocket_chat &>/dev/null &


================================================ docker centos
-----------------------------
docker run --privileged -it -d --name "docker_1" centos-fep-irp
docker ps -a
docker attach docker_1

[root@f7e85d87d331 /]# yum install iptables tcpdump

docker stop docker_1
docker start docker_1
docker rm docker_1
-----------------------------
systemctl start docker
systemctl stop docker
systemctl status docker
systemctl enable docker
-----------------------------
docker images

docker tag a8493f5f50ff docker.io/centos:quagga
docker rmi docker.io/centos:quagga

docker run --privileged -it --rm centos:quagga /bin/bash

//List Containers
docker ps
docker ps -a
docker ps -l
//Attach to a Specific Container
docker attach 9c09acd48a25
-----------------------------
(Host)
// Saving the Image
docker ps -a
docker commit f7e85d87d331 centos-fep-irp
docker images

[root@localhost fep-irp]# docker images
REPOSITORY          TAG                 IMAGE ID            CREATED             SIZE
centos-fep-irp      latest              6d7988b95ede        31 seconds ago      553.9 MB
docker.io/centos    latest              a8493f5f50ff        2 weeks ago         192.5 MB
[root@localhost fep-irp]# 

(Docker)
[root@a9135687be7c etc]# exit



================== testing: lineage & dockers: 3x3 matrix, 4x4 matrix, 5×5 matrix, 6x6 matrix, 7x7 matrix - begin

### (in IBM Server)

# NS3 scripts

cd /opt/tools/network_simulators/ns3/ns-allinone-3.26/ns-3.26/scratch
fep-manet-3x3-0.cc
fep-manet-4x4-0.cc
fep-manet-5x5-0.cc
fep-manet-6x6-0.cc
fep-manet-7x7-0.cc
fep-manet-8x8-0.cc


###---------------------------------------------------------------------------------------- begin
#
# testing docker matrix, 获得 CPU, MEMORY, 网络性能的 统计信息
#
###----------------------------------------------------------------------------------------


###---------------------------------------------------------
# 以下面这段，即【 3x3 matrix】，为模板复制【 4x4 matrix】时，要替换 19 处 3x3，替换 3 处 9。
###---------------------------------------------------------

###---------------------------------------------------------
#
# docker: 3x3 matrix
#
###---------------------------------------------------------
# (in Host)
#-- log-stats-cpu-memory-3x3.txt 记录本轮实验 整个过程的 CPU, MEMORY 统计信息
cd /mnt/vm_img/fep-irp-nougat/
./stats-cpu-memory.sh > log-stats-cpu-memory-3x3.txt

#-- log_3x3.txt 记录 ./fep-irp-auto-run-vbox-and-docker.sh, ./waf --run 启动的时间点
cd /mnt/vm_img/fep-irp-nougat/
/bin/rm log_3x3.txt
echo "==================================" >> log_3x3.txt
date +%H:%M:%S >> log_3x3.txt
echo "./fep-irp-auto-run-vbox-and-docker.sh create" >> log_3x3.txt
echo "==================================" >> log_3x3.txt
./fep-irp-auto-run-vbox-and-docker.sh create 9 0 centos-fep-irp lineage-irp- /mnt/vm_img/fep-irp-nougat

cd /mnt/vm_img/fep-irp-nougat/
echo "==================================" >> log_3x3.txt
date +%H:%M:%S >> log_3x3.txt
echo "./waf --run scratch/fep-manet --vis &" >> log_3x3.txt
echo "==================================" >> log_3x3.txt
cd /opt/tools/network_simulators/ns3/ns-allinone-3.26/ns-3.26
./waf --run scratch/fep-manet-3x3-0 --vis

# (in docker_1)
docker attach docker_1

# (in docker_3x3)
docker attach docker_9
ping 112.26.1.1

# ping 一分钟（需要计时），得到 load average: 0.69, 0.77, 0.73
# 保存到：/opt/share-vm/fedora23server-share/fep/fep-testing-log/log_ping_3x3.txt
# 然后退出【docker_1】【docker_】

# (in Host)
echo "==================================" >> log_3x3.txt
date +%H:%M:%S >> log_3x3.txt
echo "./fep-irp-auto-run-vbox-and-docker.sh destroy" >> log_3x3.txt
echo "==================================" >> log_3x3.txt
./fep-irp-auto-run-vbox-and-docker.sh destroy 9 0 centos-fep-irp lineage-irp- /mnt/vm_img/fep-irp-nougat
# 最后【Ctrl + C】【./stats-cpu-memory.sh > log-stats-cpu-memory-.txt】
###---------------------------------------------------------


###---------------------------------------------------------
#
# docker: 4x4 matrix
#
###---------------------------------------------------------
# (in Host)
#-- log-stats-cpu-memory-4x4.txt 记录本轮实验 整个过程的 CPU, MEMORY 统计信息
cd /mnt/vm_img/fep-irp-nougat/
./stats-cpu-memory.sh > log-stats-cpu-memory-4x4.txt

#-- log_4x4.txt 记录 ./fep-irp-auto-run-vbox-and-docker.sh, ./waf --run 启动的时间点
cd /mnt/vm_img/fep-irp-nougat/
/bin/rm log_4x4.txt
echo "==================================" >> log_4x4.txt
date +%H:%M:%S >> log_4x4.txt
echo "./fep-irp-auto-run-vbox-and-docker.sh create" >> log_4x4.txt
echo "==================================" >> log_4x4.txt
./fep-irp-auto-run-vbox-and-docker.sh create 16 0 centos-fep-irp lineage-irp- /mnt/vm_img/fep-irp-nougat

cd /mnt/vm_img/fep-irp-nougat/
echo "==================================" >> log_4x4.txt
date +%H:%M:%S >> log_4x4.txt
echo "./waf --run scratch/fep-manet --vis &" >> log_4x4.txt
echo "==================================" >> log_4x4.txt
cd /opt/tools/network_simulators/ns3/ns-allinone-3.26/ns-3.26
./waf --run scratch/fep-manet-4x4-0 --vis

# (in docker_1)
docker attach docker_1

# (in docker_4x4)
docker attach docker_16
ping 112.26.1.1

# ping 一分钟（需要计时），得到 load average: 0.69, 0.77, 0.73
# 保存到：/opt/share-vm/fedora23server-share/fep/fep-testing-log/log_ping_4x4.txt
# 然后退出【docker_1】【docker_】

# (in Host)
echo "==================================" >> log_4x4.txt
date +%H:%M:%S >> log_4x4.txt
echo "./fep-irp-auto-run-vbox-and-docker.sh destroy" >> log_4x4.txt
echo "==================================" >> log_4x4.txt
./fep-irp-auto-run-vbox-and-docker.sh destroy 16 0 centos-fep-irp lineage-irp- /mnt/vm_img/fep-irp-nougat
# 最后【Ctrl + C】【./stats-cpu-memory.sh > log-stats-cpu-memory-.txt】
###---------------------------------------------------------


###---------------------------------------------------------
#
# docker: 5x5 matrix
#
###---------------------------------------------------------
# (in Host)
#-- log-stats-cpu-memory-5x5.txt 记录本轮实验 整个过程的 CPU, MEMORY 统计信息
cd /mnt/vm_img/fep-irp-nougat/
./stats-cpu-memory.sh > log-stats-cpu-memory-5x5.txt

#-- log_5x5.txt 记录 ./fep-irp-auto-run-vbox-and-docker.sh, ./waf --run 启动的时间点
cd /mnt/vm_img/fep-irp-nougat/
/bin/rm log_5x5.txt
echo "==================================" >> log_5x5.txt
date +%H:%M:%S >> log_5x5.txt
echo "./fep-irp-auto-run-vbox-and-docker.sh create" >> log_5x5.txt
echo "==================================" >> log_5x5.txt
./fep-irp-auto-run-vbox-and-docker.sh create 25 0 centos-fep-irp lineage-irp- /mnt/vm_img/fep-irp-nougat

cd /mnt/vm_img/fep-irp-nougat/
echo "==================================" >> log_5x5.txt
date +%H:%M:%S >> log_5x5.txt
echo "./waf --run scratch/fep-manet --vis &" >> log_5x5.txt
echo "==================================" >> log_5x5.txt
cd /opt/tools/network_simulators/ns3/ns-allinone-3.26/ns-3.26
./waf --run scratch/fep-manet-5x5-0 --vis

# (in docker_1)
docker attach docker_1

# (in docker_5x5)
docker attach docker_25
ping 112.26.1.1

# ping 一分钟（需要计时），得到 load average: 0.69, 0.77, 0.73
# 保存到：/opt/share-vm/fedora23server-share/fep/fep-testing-log/log_ping_5x5.txt
# 然后退出【docker_1】【docker_】

# (in Host)
echo "==================================" >> log_5x5.txt
date +%H:%M:%S >> log_5x5.txt
echo "./fep-irp-auto-run-vbox-and-docker.sh destroy" >> log_5x5.txt
echo "==================================" >> log_5x5.txt
./fep-irp-auto-run-vbox-and-docker.sh destroy 25 0 centos-fep-irp lineage-irp- /mnt/vm_img/fep-irp-nougat
echo "==================================" >> log_5x5.txt
date +%H:%M:%S >> log_5x5.txt
echo "./fep-irp-auto-run-vbox-and-docker.sh destroy OK" >> log_5x5.txt
echo "==================================" >> log_5x5.txt
# 最后【Ctrl + C】【./stats-cpu-memory.sh > log-stats-cpu-memory-.txt】
###---------------------------------------------------------


###---------------------------------------------------------
#
# docker: 6x6 matrix
#
###---------------------------------------------------------
# (in Host)
#-- log-stats-cpu-memory-6x6.txt 记录本轮实验 整个过程的 CPU, MEMORY 统计信息
cd /mnt/vm_img/fep-irp-nougat/
./stats-cpu-memory.sh > log-stats-cpu-memory-6x6.txt

#-- log_6x6.txt 记录 ./fep-irp-auto-run-vbox-and-docker.sh, ./waf --run 启动的时间点
cd /mnt/vm_img/fep-irp-nougat/
/bin/rm log_6x6.txt
echo "==================================" >> log_6x6.txt
date +%H:%M:%S >> log_6x6.txt
echo "./fep-irp-auto-run-vbox-and-docker.sh create" >> log_6x6.txt
echo "==================================" >> log_6x6.txt
./fep-irp-auto-run-vbox-and-docker.sh create 36 0 centos-fep-irp lineage-irp- /mnt/vm_img/fep-irp-nougat

cd /mnt/vm_img/fep-irp-nougat/
echo "==================================" >> log_6x6.txt
date +%H:%M:%S >> log_6x6.txt
echo "./waf --run scratch/fep-manet --vis &" >> log_6x6.txt
echo "==================================" >> log_6x6.txt
cd /opt/tools/network_simulators/ns3/ns-allinone-3.26/ns-3.26
./waf --run scratch/fep-manet-6x6-0 --vis

# (in docker_1)
docker attach docker_1

# (in docker_6x6)
docker attach docker_36
ping 112.26.1.1

# ping 一分钟（需要计时），得到 load average: 0.69, 0.77, 0.73
# 保存到：/opt/share-vm/fedora23server-share/fep/fep-testing-log/log_ping_6x6.txt
# 然后退出【docker_1】【docker_】

# (in Host)
echo "==================================" >> log_6x6.txt
date +%H:%M:%S >> log_6x6.txt
echo "./fep-irp-auto-run-vbox-and-docker.sh destroy" >> log_6x6.txt
echo "==================================" >> log_6x6.txt
./fep-irp-auto-run-vbox-and-docker.sh destroy 36 0 centos-fep-irp lineage-irp- /mnt/vm_img/fep-irp-nougat
echo "==================================" >> log_6x6.txt
date +%H:%M:%S >> log_6x6.txt
echo "./fep-irp-auto-run-vbox-and-docker.sh destroy OK" >> log_6x6.txt
echo "==================================" >> log_6x6.txt
# 最后【Ctrl + C】【./stats-cpu-memory.sh > log-stats-cpu-memory-.txt】
###---------------------------------------------------------


###---------------------------------------------------------
#
# docker: 7x7 matrix
#
###---------------------------------------------------------
# (in Host)
#-- log-stats-cpu-memory-7x7.txt 记录本轮实验 整个过程的 CPU, MEMORY 统计信息
cd /mnt/vm_img/fep-irp-nougat/
./stats-cpu-memory.sh > log-stats-cpu-memory-7x7.txt

#-- log_7x7.txt 记录 ./fep-irp-auto-run-vbox-and-docker.sh, ./waf --run 启动的时间点
cd /mnt/vm_img/fep-irp-nougat/
/bin/rm log_7x7.txt
echo "==================================" >> log_7x7.txt
date +%H:%M:%S >> log_7x7.txt
echo "./fep-irp-auto-run-vbox-and-docker.sh create" >> log_7x7.txt
echo "==================================" >> log_7x7.txt
./fep-irp-auto-run-vbox-and-docker.sh create 49 0 centos-fep-irp lineage-irp- /mnt/vm_img/fep-irp-nougat

cd /mnt/vm_img/fep-irp-nougat/
echo "==================================" >> log_7x7.txt
date +%H:%M:%S >> log_7x7.txt
echo "./waf --run scratch/fep-manet --vis &" >> log_7x7.txt
echo "==================================" >> log_7x7.txt
cd /opt/tools/network_simulators/ns3/ns-allinone-3.26/ns-3.26
./waf --run scratch/fep-manet-7x7-0 --vis

# (in docker_1)
docker attach docker_1

# (in docker_7x7)
docker attach docker_49
ping 112.26.1.1

# ping 一分钟（需要计时），得到 load average: 0.69, 0.77, 0.73
# 保存到：/opt/share-vm/fedora23server-share/fep/fep-testing-log/log_ping_7x7.txt
# 然后退出【docker_1】【docker_】

# (in Host)
echo "==================================" >> log_7x7.txt
date +%H:%M:%S >> log_7x7.txt
echo "./fep-irp-auto-run-vbox-and-docker.sh destroy" >> log_7x7.txt
echo "==================================" >> log_7x7.txt
./fep-irp-auto-run-vbox-and-docker.sh destroy 49 0 centos-fep-irp lineage-irp- /mnt/vm_img/fep-irp-nougat
echo "==================================" >> log_7x7.txt
date +%H:%M:%S >> log_7x7.txt
echo "./fep-irp-auto-run-vbox-and-docker.sh destroy OK" >> log_7x7.txt
echo "==================================" >> log_7x7.txt
# the 4 lines above are used to get the time to destroy 49 centos-fep-irp
# 最后【Ctrl + C】【./stats-cpu-memory.sh > log-stats-cpu-memory-.txt】
###---------------------------------------------------------


###---------------------------------------------------------
#
# docker: 8x8 matrix
#
###---------------------------------------------------------
# (in Host)
#-- log-stats-cpu-memory-8x8.txt 记录本轮实验 整个过程的 CPU, MEMORY 统计信息
cd /mnt/vm_img/fep-irp-nougat/
./stats-cpu-memory.sh > log-stats-cpu-memory-8x8.txt

#-- log_8x8.txt 记录 ./fep-irp-auto-run-vbox-and-docker.sh, ./waf --run 启动的时间点
cd /mnt/vm_img/fep-irp-nougat/
/bin/rm log_8x8.txt
echo "==================================" >> log_8x8.txt
date +%H:%M:%S >> log_8x8.txt
echo "./fep-irp-auto-run-vbox-and-docker.sh create" >> log_8x8.txt
echo "==================================" >> log_8x8.txt
./fep-irp-auto-run-vbox-and-docker.sh create 64 0 centos-fep-irp lineage-irp- /mnt/vm_img/fep-irp-nougat

cd /mnt/vm_img/fep-irp-nougat/
echo "==================================" >> log_8x8.txt
date +%H:%M:%S >> log_8x8.txt
echo "./waf --run scratch/fep-manet --vis &" >> log_8x8.txt
echo "==================================" >> log_8x8.txt
cd /opt/tools/network_simulators/ns3/ns-allinone-3.26/ns-3.26
./waf --run scratch/fep-manet-8x8-0 --vis

# (in docker_1)
docker attach docker_1

# (in docker_8x8)
docker attach docker_64
ping 112.26.1.1

# ping 一分钟（需要计时），得到 load average: 0.69, 0.77, 0.73
# 保存到：/opt/share-vm/fedora23server-share/fep/fep-testing-log/log_ping_8x8.txt
# 然后退出【docker_1】【docker_】

# (in Host)
echo "==================================" >> log_8x8.txt
date +%H:%M:%S >> log_8x8.txt
echo "./fep-irp-auto-run-vbox-and-docker.sh destroy" >> log_8x8.txt
echo "==================================" >> log_8x8.txt
./fep-irp-auto-run-vbox-and-docker.sh destroy 64 0 centos-fep-irp lineage-irp- /mnt/vm_img/fep-irp-nougat
echo "==================================" >> log_8x8.txt
date +%H:%M:%S >> log_8x8.txt
echo "./fep-irp-auto-run-vbox-and-docker.sh destroy OK" >> log_8x8.txt
echo "==================================" >> log_8x8.txt
# the 4 lines above are used to get the time to destroy 64 centos-fep-irp
# 最后【Ctrl + C】【./stats-cpu-memory.sh > log-stats-cpu-memory-.txt】
###---------------------------------------------------------



###---------------------------------------------------------
#
# docker: 8x8 matrix
#
###---------------------------------------------------------

cd /mnt/vm_img/fep-irp-nougat/
./fep-irp-auto-run-vbox-and-docker.sh create 64 0 centos-fep-irp lineage-irp- /mnt/vm_img/fep-irp-nougat
./fep-irp-auto-run-vbox-and-docker.sh destroy 64 0 centos-fep-irp lineage-irp- /mnt/vm_img/fep-irp-nougat

cd /opt/tools/network_simulators/ns3/ns-allinone-3.26/ns-3.26
./waf --run scratch/fep-manet-8x8-0 --vis

# (in docker_1)
docker attach docker_1

# (in docker_7x7)
docker attach docker_64
ping 112.26.1.1

###---------------------------------------------------------


###---------------------------------------------------------------------------------------- end



###---------------------------------------------------------------------------------------- begin
#
# testing lineage, 获得 CPU, MEMORY 统计信息
#
###----------------------------------------------------------------------------------------

###---------------------------------------------------------
#
# number of lineages: 3
#
###---------------------------------------------------------
# (in Host)
cd /mnt/vm_img/fep-irp-nougat/
./stats-cpu-memory.sh > log-stats-cpu-memory-lineage-3.txt

#-- log_lineage_3.txt 记录 ./fep-irp-auto-run-vbox-and-docker.sh create, destroy 的时间点
cd /mnt/vm_img/fep-irp-nougat/
/bin/rm log_lineage_3.txt
echo "==================================" >> log_lineage_3.txt
date +%H:%M:%S >> log_lineage_3.txt
echo "./fep-irp-auto-run-vbox-and-docker.sh create" >> log_lineage_3.txt
echo "==================================" >> log_lineage_3.txt
./fep-irp-auto-run-vbox-and-docker.sh create 0 3 centos-fep-irp lineage-irp- /mnt/vm_img/fep-irp-nougat

echo "==================================" >> log_lineage_3.txt
date +%H:%M:%S >> log_lineage_3.txt
echo "./fep-irp-auto-run-vbox-and-docker.sh destroy" >> log_lineage_3.txt
echo "==================================" >> log_lineage_3.txt
./fep-irp-auto-run-vbox-and-docker.sh destroy 0 3 centos-fep-irp lineage-irp- /mnt/vm_img/fep-irp-nougat
echo "==================================" >> log_lineage_3.txt
date +%H:%M:%S >> log_lineage_3.txt
echo "./fep-irp-auto-run-vbox-and-docker.sh destroy OK" >> log_lineage_3.txt
echo "==================================" >> log_lineage_3.txt

###---------------------------------------------------------


###---------------------------------------------------------
#
# number of lineages: 4
#
###---------------------------------------------------------
# (in Host)
cd /mnt/vm_img/fep-irp-nougat/
./stats-cpu-memory.sh > log-stats-cpu-memory-lineage-4.txt

#-- log_lineage_4.txt 记录 ./fep-irp-auto-run-vbox-and-docker.sh create, destroy 的时间点
cd /mnt/vm_img/fep-irp-nougat/
/bin/rm log_lineage_4.txt
echo "==================================" >> log_lineage_4.txt
date +%H:%M:%S >> log_lineage_4.txt
echo "./fep-irp-auto-run-vbox-and-docker.sh create" >> log_lineage_4.txt
echo "==================================" >> log_lineage_4.txt
./fep-irp-auto-run-vbox-and-docker.sh create 0 4 centos-fep-irp lineage-irp- /mnt/vm_img/fep-irp-nougat

echo "==================================" >> log_lineage_4.txt
date +%H:%M:%S >> log_lineage_4.txt
echo "./fep-irp-auto-run-vbox-and-docker.sh destroy" >> log_lineage_4.txt
echo "==================================" >> log_lineage_4.txt
./fep-irp-auto-run-vbox-and-docker.sh destroy 0 4 centos-fep-irp lineage-irp- /mnt/vm_img/fep-irp-nougat
echo "==================================" >> log_lineage_4.txt
date +%H:%M:%S >> log_lineage_4.txt
echo "./fep-irp-auto-run-vbox-and-docker.sh destroy OK" >> log_lineage_4.txt
echo "==================================" >> log_lineage_4.txt
###---------------------------------------------------------


###---------------------------------------------------------
#
# number of lineages: 5
#
###---------------------------------------------------------
# (in Host)
cd /mnt/vm_img/fep-irp-nougat/
./stats-cpu-memory.sh > log-stats-cpu-memory-lineage-5.txt

#-- log_lineage_5.txt 记录 ./fep-irp-auto-run-vbox-and-docker.sh create, destroy 的时间点
cd /mnt/vm_img/fep-irp-nougat/
/bin/rm log_lineage_5.txt
echo "==================================" >> log_lineage_5.txt
date +%H:%M:%S >> log_lineage_5.txt
echo "./fep-irp-auto-run-vbox-and-docker.sh create" >> log_lineage_5.txt
echo "==================================" >> log_lineage_5.txt
./fep-irp-auto-run-vbox-and-docker.sh create 0 5 centos-fep-irp lineage-irp- /mnt/vm_img/fep-irp-nougat

echo "==================================" >> log_lineage_5.txt
date +%H:%M:%S >> log_lineage_5.txt
echo "./fep-irp-auto-run-vbox-and-docker.sh destroy" >> log_lineage_5.txt
echo "==================================" >> log_lineage_5.txt
./fep-irp-auto-run-vbox-and-docker.sh destroy 0 5 centos-fep-irp lineage-irp- /mnt/vm_img/fep-irp-nougat
echo "==================================" >> log_lineage_5.txt
date +%H:%M:%S >> log_lineage_5.txt
echo "./fep-irp-auto-run-vbox-and-docker.sh destroy OK" >> log_lineage_5.txt
echo "==================================" >> log_lineage_5.txt
###---------------------------------------------------------


###---------------------------------------------------------
#
# number of lineages: 6
#
###---------------------------------------------------------
# (in Host)
cd /mnt/vm_img/fep-irp-nougat/
./stats-cpu-memory.sh > log-stats-cpu-memory-lineage-6.txt

#-- log_lineage_6.txt 记录 ./fep-irp-auto-run-vbox-and-docker.sh create, destroy 的时间点
cd /mnt/vm_img/fep-irp-nougat/
/bin/rm log_lineage_6.txt
echo "==================================" >> log_lineage_6.txt
date +%H:%M:%S >> log_lineage_6.txt
echo "./fep-irp-auto-run-vbox-and-docker.sh create" >> log_lineage_6.txt
echo "==================================" >> log_lineage_6.txt
./fep-irp-auto-run-vbox-and-docker.sh create 0 6 centos-fep-irp lineage-irp- /mnt/vm_img/fep-irp-nougat

echo "==================================" >> log_lineage_6.txt
date +%H:%M:%S >> log_lineage_6.txt
echo "./fep-irp-auto-run-vbox-and-docker.sh destroy" >> log_lineage_6.txt
echo "==================================" >> log_lineage_6.txt
./fep-irp-auto-run-vbox-and-docker.sh destroy 0 6 centos-fep-irp lineage-irp- /mnt/vm_img/fep-irp-nougat
echo "==================================" >> log_lineage_6.txt
date +%H:%M:%S >> log_lineage_6.txt
echo "./fep-irp-auto-run-vbox-and-docker.sh destroy OK" >> log_lineage_6.txt
echo "==================================" >> log_lineage_6.txt
###---------------------------------------------------------


###---------------------------------------------------------
#
# number of lineages: 7
#
###---------------------------------------------------------
# (in Host)
cd /mnt/vm_img/fep-irp-nougat/
./stats-cpu-memory.sh > log-stats-cpu-memory-lineage-7.txt

#-- log_lineage_7.txt 记录 ./fep-irp-auto-run-vbox-and-docker.sh create, destroy 的时间点
cd /mnt/vm_img/fep-irp-nougat/
/bin/rm log_lineage_7.txt
echo "==================================" >> log_lineage_7.txt
date +%H:%M:%S >> log_lineage_7.txt
echo "./fep-irp-auto-run-vbox-and-docker.sh create" >> log_lineage_7.txt
echo "==================================" >> log_lineage_7.txt
./fep-irp-auto-run-vbox-and-docker.sh create 0 7 centos-fep-irp lineage-irp- /mnt/vm_img/fep-irp-nougat

echo "==================================" >> log_lineage_7.txt
date +%H:%M:%S >> log_lineage_7.txt
echo "./fep-irp-auto-run-vbox-and-docker.sh destroy" >> log_lineage_7.txt
echo "==================================" >> log_lineage_7.txt
./fep-irp-auto-run-vbox-and-docker.sh destroy 0 7 centos-fep-irp lineage-irp- /mnt/vm_img/fep-irp-nougat
echo "==================================" >> log_lineage_7.txt
date +%H:%M:%S >> log_lineage_7.txt
echo "./fep-irp-auto-run-vbox-and-docker.sh destroy OK" >> log_lineage_7.txt
echo "==================================" >> log_lineage_7.txt
###---------------------------------------------------------



###---------------------------------------------------------
#
# number of lineages: 8
#
###---------------------------------------------------------
# (in Host)
cd /mnt/vm_img/fep-irp-nougat/
./stats-cpu-memory.sh > log-stats-cpu-memory-lineage-8.txt

#-- log_lineage_8.txt 记录 ./fep-irp-auto-run-vbox-and-docker.sh create, destroy 的时间点
cd /mnt/vm_img/fep-irp-nougat/
/bin/rm log_lineage_8.txt
echo "==================================" >> log_lineage_8.txt
date +%H:%M:%S >> log_lineage_8.txt
echo "./fep-irp-auto-run-vbox-and-docker.sh create" >> log_lineage_8.txt
echo "==================================" >> log_lineage_8.txt
./fep-irp-auto-run-vbox-and-docker.sh create 0 8 centos-fep-irp lineage-irp- /mnt/vm_img/fep-irp-nougat

echo "==================================" >> log_lineage_8.txt
date +%H:%M:%S >> log_lineage_8.txt
echo "./fep-irp-auto-run-vbox-and-docker.sh destroy" >> log_lineage_8.txt
echo "==================================" >> log_lineage_8.txt
./fep-irp-auto-run-vbox-and-docker.sh destroy 0 8 centos-fep-irp lineage-irp- /mnt/vm_img/fep-irp-nougat
echo "==================================" >> log_lineage_8.txt
date +%H:%M:%S >> log_lineage_8.txt
echo "./fep-irp-auto-run-vbox-and-docker.sh destroy OK" >> log_lineage_8.txt
echo "==================================" >> log_lineage_8.txt
###---------------------------------------------------------

###---------------------------------------------------------------------------------------- end


================== testing: lineage & dockers: 3x3 matrix, 4x4 matrix, 5×5 matrix, 6x6 matrix, 7x7 matrix - end



