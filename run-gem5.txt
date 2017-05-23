[root@localhost my-gem5]# pwd
/run/media/root/158a840e-63fa-4544-b0b8-dc0d40c79241/my-gem5/

[root@localhost my-gem5]# ls
aarch-system-2014-10.tar.xz  mediaBench.zip  Mibench.tgz  my-gem5.tar.gz
[root@localhost my-gem5]# tar xzf my-gem5.tar.gz -C my-gem5

[root@localhost my-gem5]# cd my-gem5
/run/media/root/158a840e-63fa-4544-b0b8-dc0d40c79241/my-gem5/my-gem5

[root@localhost my-gem5]# mkdir img
[root@localhost my-gem5]# cd ..
[root@localhost my-gem5]# tar -xJf aarch-system-2014-10.tar.xz -C my-gem5/img/
[root@localhost my-gem5]# cd my-gem5

[root@localhost my-gem5]# pwd
/run/media/root/158a840e-63fa-4544-b0b8-dc0d40c79241/my-gem5
[root@localhost my-gem5]# ls
aarch-system-2014-10.tar.xz  mediaBench  mediaBench.zip  Mibench  Mibench.tgz  my-gem5  my-gem5.tar.gz
[root@localhost my-gem5]# mount -o loop,offset=32256 my-gem5/img/disks/linux-aarch32-ael.img /mnt/tmp/
[root@localhost my-gem5]# cp -a mediaBench /mnt/tmp/
[root@localhost my-gem5]# cp -a Mibench /mnt/tmp/
[root@localhost my-gem5]# cd /mnt/tmp/
[root@localhost tmp]# chmod +x mediaBench/* -R
[root@localhost tmp]# chmod +x Mibench/* -R
[root@localhost tmp]# cd -
/run/media/root/158a840e-63fa-4544-b0b8-dc0d40c79241/my-gem5
[root@localhost my-gem5]# umount /mnt/tmp/
[root@localhost my-gem5]#

//Enter directory parsec-1 

[root@localhost my-gem5]# cd my-gem5/parsec-1/
ln -s /opt/gem5/gem5/gem5-stable/build/ARM/gem5.opt ./
ln -s /opt/gem5/gem5/gem5-stable/configs/ ./


[root@localhost parsec-1]# pwd
/run/media/root/158a840e-63fa-4544-b0b8-dc0d40c79241/my-gem5/my-gem5/parsec-1
[root@localhost parsec-1]# ls -p
board_start.sh  configs/  gem5.opt  m5out/  tongji.sh
[root@localhost parsec-1]#


[root@localhost my-gem5]# pwd
/run/media/root/158a840e-63fa-4544-b0b8-dc0d40c79241/my-gem5
[root@localhost my-gem5]# ls
aarch-system-2014-10.tar.xz              linux-aarch32-ael.img  mediaBench.zip  Mibench.tgz  my-gem5.tar.gz
ARMv7a-ICS-Android.SMP.Asimbench-v3.img  mediaBench             Mibench         my-gem5      sdcard-1g-mxplayer.img


[root@localhost my-gem5]# cp sdcard-1g-mxplayer.img my-gem5/img/disks/sdcard-1g-mxplayer.img
[root@localhost my-gem5]# cp vexpress-v2p-ca15-tc1-gem5_dvfs_1cpus.dtb my-gem5/img/binaries/vexpress-v2p-ca15-tc1-gem5_dvfs_1cpus.dtb
[root@localhost my-gem5]#


gedit /run/media/root/158a840e-63fa-4544-b0b8-dc0d40c79241/my-gem5/my-gem5/parsec-1/board_start.sh
#----------------
#!/bin/bash
export M5_PATH=../img/
#### android boot
./gem5.opt configs/example/fs.py --os-type=android-ics --mem-size=1024MB --kernel=/run/media/root/158a840e-63fa-4544-b0b8-dc0d40c79241/my-gem5/vmlinux-gem5-android-dvfs --disk-image=/run/media/root/158a840e-63fa-4544-b0b8-dc0d40c79241/my-gem5/ARMv7a-ICS-Android.SMP.Asimbench-v3.img --caches --l1i_size=32kB --l1d_size=32kB --l1d_assoc=2 --l1i_assoc=2 --l2_assoc=16 --l2cache --l2_size=128kB --num-l2caches=8 --cpu-type=AtomicSimpleCPU -n 1 --machine-type=VExpress_EMM --dtb-filename=vexpress-v2p-ca15-tc1-gem5_dvfs_1cpus.dtb --frame-capture
#----------------


[root@localhost parsec-1]# pwd
/run/media/root/158a840e-63fa-4544-b0b8-dc0d40c79241/my-gem5/my-gem5/parsec-1
[root@localhost parsec-1]# ls
board_start.sh  configs  gem5.opt  m5out  tongji.sh


[root@localhost parsec-1]# ./board_start.sh

./gem5.opt configs/example/fs.py --os-type=android-ics --mem-size=1024MB --kernel=/run/media/root/158a840e-63fa-4544-b0b8-dc0d40c79241/my-gem5/vmlinux-gem5-android-dvfs --disk-image=/run/media/root/158a840e-63fa-4544-b0b8-dc0d40c79241/my-gem5/ARMv7a-ICS-Android.SMP.Asimbench-v3.img --caches --l1i_size=32kB --l1d_size=32kB --l1d_assoc=2 --l1i_assoc=2 --l2_assoc=16 --l2cache --l2_size=128kB --num-l2caches=8 --cpu-type=AtomicSimpleCPU -n 1 --machine-type=VExpress_EMM --dtb-filename=vexpress-v2p-ca15-tc1-gem5_dvfs_1cpus.dtb --frame-capture

Listening for system connection on port 5900
Listening for system connection on port 3456
0: system.remote_gdb.listener: listening for remote gdb #0 on port 7000
info: Using bootloader at address 0x10
info: Using kernel entry physical address at 0x80008000
info: Loading DTB file: ../img/binaries/vexpress-v2p-ca15-tc1-gem5_dvfs_1cpus.dtb at address 0x88000000
**** REAL SIMULATION ****


[root@localhost gem5-stable]# pwd
/opt/gem5/gem5/gem5-stable
[root@localhost gem5-stable]# scons build/ARM/gem5.opt
--------------------------------
scons -c build/ARM/gem5.opt        //and if you want to re-build , you can make it clean using this command
--------------------------------
[root@localhost term]# pwd
/opt/gem5/gem5/gem5-stable/util/term
[root@localhost term]# make
[root@localhost gem5-stable]# ./util/term/m5term 127.0.0.1 3456


[root@localhost ~]# vncviewer -FullColour 127.0.0.1:5900

waiting a long time, ......
