#
# This manual is released under GNU GPL v2,v3
# Author: Tongguang Zhang
# Date: 2017-05-23
#


============================================================================= begin
How to Build Lineageos rom for any android device Easily ! {Full guide}

http://www.lineageosrom.com/2017/01/how-to-build-lineageos-rom-for-any.html
----------------------------------------------------------

++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
download and compile lineage-14.1-kiwi (begin)
++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

--------------------------------------------------------------
installed adb and fastboot
--------------------------------------------------------------
wget https://dl.google.com/android/repository/platform-tools-latest-linux.zip
unzip platform-tools-latest-linux.zip -d ~
gedit ~/.bash_profile
--------------------------
# add Android SDK platform tools to path
if [ -d "$HOME/platform-tools" ] ; then
    PATH="$HOME/platform-tools:$PATH"
fi
--------------------------

source ~/.bash_profile
--------------------------------------------------------------


--------------------------------------------------------------
download lineage-14.1-kiwi
--------------------------------------------------------------

[root@localhost lineage-14.1-kiwi]# 

curl https://storage.googleapis.com/git-repo-downloads/repo > /usr/bin/repo
chmod a+x /usr/bin/repo

repo init -u https://github.com/LineageOS/android.git -b cm-14.1

repo sync

[root@localhost lineage-14.1-kiwi]# du -hs .
39G	.
--------------------------------------------------------------


========================================= 从这里开始

## Prepare the device-specific code

[root@localhost lineage-14.1-kiwi-on-phone]# source build/envsetup.sh

			// This will download the device specific configuration and kernel source for your device.

[root@localhost lineage-14.1-kiwi-on-phone]# breakfast kiwi

			//  Start the build, Time to start building! Now, type:

			// 先不执行下面 命令进行编译，先【 Extract proprietary blobs 】
[root@localhost lineage-14.1-kiwi-on-phone]# brunch kiwi

----------------------------------------------------------
// 如果 出现如下 编译错误

Starting build with ninja
ninja: Entering directory `.'
ninja: error: '/opt/android-x86/lineage-14.1-kiwi-on-phone/out/target/product/kiwi/obj_arm/SHARED_LIBRARIES/libtfa9895_intermediates/export_includes', needed by '/opt/android-x86/lineage-14.1-kiwi-on-phone/out/target/product/kiwi/obj_arm/SHARED_LIBRARIES/audio_amplifier.msm8916_intermediates/import_includes', missing and no known rule to make it
build/core/ninja.mk:151: recipe for target 'ninja_wrapper' failed
make: *** [ninja_wrapper] Error 1
make: Leaving directory '/opt/android-x86/lineage-14.1-kiwi-on-phone'

#### make failed to build some targets (01:10 (mm:ss)) ####
----------------------------------------------------------

mkdir -p /opt/android-x86/lineage-14.1-kiwi-on-phone/out/target/product/kiwi/obj_arm/SHARED_LIBRARIES/libtfa9895_intermediates/export_includes

----------------------------------------------------------
// 如果 出现如下 编译错误

ninja: error: '/opt/android-x86/lineage-14.1-kiwi-on-phone/out/target/product/kiwi/obj_arm/lib/libtfa9895.so.toc', needed by '/opt/android-x86/lineage-14.1-kiwi-on-phone/out/target/product/kiwi/obj_arm/SHARED_LIBRARIES/audio_amplifier.msm8916_intermediates/LINKED/audio_amplifier.msm8916.so', missing and no known rule to make it
----------------------------------------------------------


## Extract proprietary blobs

## http://www.lineageosrom.com/2017/01/how-to-build-lineageos-rom-for-any.html

Now ensure your device is connected to your computer via the USB cable, with ADB and root enabled, and that you are in the /opt/android-x86/lineage-14.1-kiwi-on-phone/device/huawei/kiwi/ folder. Then run the extract-files.sh script:

/opt/android-x86/lineage-14.1-kiwi-on-phone/device/huawei/kiwi/extract-files.sh

[root@localhost lineage-14.1-kiwi-on-phone]# ls vendor/
cm  cmsdk  codeaurora  qcom

--------------------


[root@localhost lineage-14.1-kiwi-on-phone]# cd device/huawei/kiwi/

				// the proprietary files (aka “blobs”) get pulled from the device
				// and moved to the vendor/huawei directory.

[root@localhost kiwi]# ./extract-files.sh


####################################
## 编译
####################################
[root@localhost lineage-14.1-kiwi-on-phone]# source build/envsetup.sh
[root@localhost lineage-14.1-kiwi-on-phone]# export WITH_SU=true
[root@localhost lineage-14.1-kiwi-on-phone]# brunch kiwi

-------------------- 编译成功，结果如下：
Package Complete: /opt/android-x86/lineage-14.1-kiwi-on-phone/out/target/product/kiwi/lineage-14.1-201703026-UNOFFICIAL-kiwi.zip
make: Leaving directory '/opt/android-x86/lineage-14.1-kiwi-on-phone'
--------------------

####################################
## 刷机
####################################

================================================ 安装  自己编译的 LineageOS 14.1 - begin - OK - 成功

scp 10.109.253.80:/opt/android-x86/lineage-14.1-kiwi-on-phone/out/target/product/kiwi/lineage-14.1-201703026-UNOFFICIAL-kiwi.zip .

adb reboot recovery			// twrp-3.0.2-0-kiwi.img

进入【recovery】模式，4 清 (dalvik/cache & cache & data & system)，
					然后，选择 lineage-14.1-201703026-UNOFFICIAL-kiwi.zip (473M)，成功刷入。

重启，等待 大概 5 分钟，进入 lineage-14.1-201703026-UNOFFICIAL-kiwi 系统

================================================ 安装  自己编译的 LineageOS 14.1 - end - OK - 成功

########################################  至此，成功 安装 自己 编译的 lineage-14.1



