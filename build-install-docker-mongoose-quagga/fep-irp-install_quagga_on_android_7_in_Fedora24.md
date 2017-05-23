#
# This manual is released under GNU GPL v2,v3
# Author: Tongguang Zhang
# Date: 2017-05-23
#

(Android Nougat 7.0 - API 24)
wget http://downloads.pf.itd.nrl.navy.mil/ospf-manet/nightly_snapshots/quagga-svnsnap.tgz


[root@localhost android-on-linux]# pwd
/opt/android-on-linux
[root@localhost android-on-linux]# tar xzf quagga-svnsnap-2017-04-20.tgz
[root@localhost android-on-linux]# cd quagga


[root@localhost quagga]# cd /opt/android-on-linux/quagga
[root@localhost quagga]# ./bootstrap.sh

export NDK_ROOT="/opt/android-on-linux/android-ndk-r14b"
export SYSROOT="$NDK_ROOT/platforms/android-24/arch-x86_64"
export CFLAGS="-g --pipe --sysroot=$SYSROOT -fPIC -fpic -I$NDK_ROOT/toolchains/x86_64-4.9/prebuilt/linux-x86_64/lib/gcc/x86_64-linux-android/4.9.x/include-fixed/ -I$NDK_ROOT/platforms/android-24/arch-x86_64/usr/include -I$NDK_ROOT/sources/cxx-stl/llvm-libc++/include/ -I$NDK_ROOT/sources/android/support/include/"
export CPPFLAGS="$CFLAGS"
export CXXFLAGS="$CFLAGS"
export LDFLAGS="--sysroot=$SYSROOT -fPIE -fpie -L$NDK_ROOT/platforms/android-24/arch-x86_64/usr/lib64/ -L$NDK_ROOT/sources/cxx-stl/stlport/libs/x86_64 -L$NDK_ROOT/sources/cxx-stl/llvm-libc++/libs/x86_64 -L$NDK_ROOT/sources/cxx-stl/gnu-libstdc++/4.9/libs/x86_64 -lstlport_shared -lm -lc++ -lc"
export CPATH="/opt/android-on-linux/android-ndk-r14b/toolchains/x86_64-4.9/prebuilt/linux-x86_64/bin"
export CPP="$CPATH/x86_64-linux-android-cpp"
export CXX="$CPATH/x86_64-linux-android-g++"
export CC="$CPATH/x86_64-linux-android-gcc"
export LD="$CPATH/x86_64-linux-android-ld"
export AR="$CPATH/x86_64-linux-android-ar"
export STRIP="$CPATH/x86_64-linux-android-strip"
export OBJDUMP="$CPATH/x86_64-linux-android-objdump"
export RANLIB="$CPATH/x86_64-linux-android-ranlib"

# ---------------------------------------------- use
./configure --host=x86_64-android-linux \
 --enable-user=root \
 --enable-group=root \
 --prefix=/opt/android-on-linux/quagga/out
# ----------------------------------------------

# ---------------------------------------------- no use，仅供参考，
./configure --host=arm-linux \
 --disable-bgpd \
 --disable-ripd \
 --disable-ripngd \
 --disable-isisd \
 --enable-ipv6 \
 --disable-vtysh \
 --disable-shared \
 --enable-static \
 --enable-user=root \
 --enable-group=root \
 --enable-vty-group=root \
 --prefix=/foobar \
 --bindir=/system/xbin \
 --sbindir=/system/xbin \
 --libexecdir=/system/xbin \
 --sysconfdir=/data/system/etc/quagga \
 --localstatedir=/data/system/var/run/quagga

make -e
rm -rf /data /system
make install
$STRIP /system/xbin/*
mkdir -p /data/system/etc/quagga
# Put configuration files in /data/system/etc/quagga
( cd /data/system/etc/quagga ; touch zebra.conf ospfd.conf ospf6d.conf babeld.conf )
( cd /data/system/etc/quagga ; chown root.root * ; chmod 644 * )
mkdir -p /data/system/var/run/quagga
chown root.root /data/system/var/run/quagga
chmod 755 /data/system/var/run/quagga
tar cvf quagga-0.99.21mr2.2-arm.tar /data /system
# ----------------------------------------------



-------------------------------------------------
gedit Makefile
-------------------------------------------------
INCLUDES = -I/usr/inet6/include -->  INCLUDES =
-------------------------------------------------

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

#################################### 定位到错点 - begin
-------------------------------------------------		错误信息如下 2 行：
sendmsg failed: ifindex: 4: Network is unreachable (101)
Could not send entire message length 44 != -1
-------------------------------------------------

# ERROE - Android - quagga - can not send 【 DbDesc 】【 Network is unreachable 】
# http://blog.csdn.net/ztguang/article/details/71024124


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
    zlog_warn ("sendmsg failed: ifindex: %d: %s (%d)",			// 执行到了这里，应该是 sendmsg 调用失败
               *ifindex, safe_strerror (errno), errno);

  return retval;
}
-------------------------------------------------

#################################### 定位到错点 - end


#################################### Android(MPTCP)  定位到错点 - begin
-------------------------------------------------		错误信息如下 2 行：
sendmsg failed: ifindex: 4: Invalid argument (22)
Could not send entire message length 52 != -1
-------------------------------------------------

# ERROE - Android(MPTCP) - quagga - sendmsg【 Invalid argument 】
# http://blog.csdn.net/ztguang/article/details/71056540

------------------------------------------------- 没有验证下面的作用 - no use
find /proc/sys/net/ipv6/conf/eth0/ -print -exec cat {} \;

echo -1 > /proc/sys/net/ipv6/conf/eth0/router_solicitations
echo 0 > /proc/sys/net/ipv6/conf/eth0/optimistic_dad
echo 1 > /proc/sys/net/ipv6/conf/eth0/accept_ra
-------------------------------------------------

#################################### Android(MPTCP)  定位到错点 - end


#################################### Android(MPTCP) ping6 - begin

命令：ping6 自己的ipv6地址
输出：正常

命令：ping6 fe80::6463:feff:fe12:8666%eth0
输出：ping: sendmsg: Network is unreachable
原因：两个节点距离近时，可以 ping6 通，距离远时，输出 Network is unreachable

或者下面错误
命令：ping6 fe80::6463:feff:fe12:8666%eth0
输出：connect: Cannot assign requested address

#################################### Android(MPTCP) ping6 - end

# ============================================================= 打开调试功能 - end


make -j4
make install


-------------------------------------------------
gedit lib/daemon.c
------------------------------------------------- no use
int
daemon (int nochdir, int noclose)
{
//printf ("daemon-----888-pid:%d--fd:%d\n", pid, fd);
							// 注释掉下面这段，可以 printf 更多信息，便于 debug，以后要还原
//if (! noclose)
  if (0)
  {
      int fd;

      fd = open ("/dev/null", O_RDWR, 0);
      if (fd != -1)
	{
	  dup2 (fd, STDIN_FILENO);
	  dup2 (fd, STDOUT_FILENO);
	  dup2 (fd, STDERR_FILENO);
	  if (fd > 2)
	    close (fd);
	}
  }
}
-------------------------------------------------
gedit zebra/main.c
gedit ospf6d/ospf6_main.c
gedit lib/daemon.c
gedit lib/thread.c
gedit zebra/zserv.c		zebra_client_read() --> zread_ipv4_add()  &  zread_ipv4_delete()
gedit zebra/zebra_rib.c		rib_process() //对路由信息的处理，整个内核的路由的新旧比较与更新
-------------------------------------------------
--------------------------------
gedit zebra/zebra_rib.c		// 添加 56 处 printf("%s == %s == %d\n", __FILE__, __FUNCTION__, __LINE__);
--------------------------------
gedit zebra/zserv.c		// 添加 34 处 printf("%s == %s == %d\n", __FILE__, __FUNCTION__, __LINE__);
--------------------------------
gedit ospf6d/ospf6_mdr_flood.c	// 添加 07 处 printf("%s == %s == %d\n", __FILE__, __FUNCTION__, __LINE__);
--------------------------------
gedit zebra/zebra_rib.c zebra/zserv.c ospf6d/ospf6_mdr_flood.c
--------------------------------

make -j4
make install


-------------------------------------------------
./zebra.h:54:23: fatal error: sys/fcntl.h: No such file or directory
 #include <sys/fcntl.h>
-------------------------------------------------
gedit lib/zebra.h
-------------------------------------------------
//#include <sys/fcntl.h>
-------------------------------------------------

-------------------------------------------------
gedit lib/log.c
-------------------------------------------------
      else if (strncmp (s, "bg", 2) == 0)
	return ZEBRA_ROUTE_BGP;
//    else if (strncmp (s, "ba", 2) == 0)		// del the line, add the below 7 lines
      else if (strncmp (s, "h", 1) == 0)
	return ZEBRA_ROUTE_HSLS;
      else if (strncmp (s, "ol", 2) == 0)
	return ZEBRA_ROUTE_OLSR;
//    else if (strncmp (s, "bat", 3) == 0)
//	return ZEBRA_ROUTE_BATMAN;
      else if (strncmp (s, "bab", 3) == 0)
	return ZEBRA_ROUTE_BABEL;
    }
  if (afi == AFI_IP6)
-------------------------------------------------

-------------------------------------------------
gedit ospf6d/ospf6_mdr_smf.c
-------------------------------------------------
#include <sys/socket.h>					// add the line
#include <sys/un.h>
-------------------------------------------------


make -j4


-------------------------------------------------
../lib/.libs/libzebra.so: error: undefined reference to 'crypt'
-------------------------------------------------
关于该错误的解决，下面的两种方案（是否使用 crypt.c & crypt.h）都可行。（docker 和 android 中要一致，都使用或都不使用 crypt）
-------------------------------------------------
grep -v crypt_key -R . |grep -v crypt_crypt |grep -v crypto|grep -v encrypt|grep -v _crypt|grep -v crypt_|grep crypt
-------------------------------------------------
gedit lib/vty.c
-------------------------------------------------
//  char *crypt (const char *, const char *);			// del the line

  if (passwd)							// del the below 6 lines
//{
//    if (host.encrypt)
//	fail = strcmp (crypt(buf, passwd), passwd);
//    else
//	fail = strcmp (buf, passwd);
//}
    fail = strcmp (buf, passwd);				// add the line
  else
    fail = 1;
-------------------------------------------------
gedit lib/command.c
-------------------------------------------------
//  char *crypt (const char *, const char *);

//  return crypt (passwd, salt);
  return passwd;
-------------------------------------------------
gedit configure
-------------------------------------------------
  /* LIBS="-lcrypt $LIBS" */
  LIBS=" $LIBS"

  /* LIBS="-lm $LIBS" */
  LIBS=" $LIBS"
  /* LIBM="-lm" */
  LIBM=""
-------------------------------------------------

make -j4


-------------------------------------------------
xorp/libxorp/ipv4.hh:471:48: error: macro "static_assert" requires 2 arguments, but only 1 given
xorp/libxorp/ipv6.hh:425:52: error: macro "static_assert" requires 2 arguments, but only 1 given
-------------------------------------------------
[root@localhost quagga]# gedit ./xpimd/xorp/libxorp/ipv4.hh

	//static_assert(sizeof(IPv4) == sizeof(uint32_t));
	static_assert(sizeof(IPv4) == sizeof(uint32_t), "");

[root@localhost quagga]# gedit ./xpimd/xorp/libxorp/ipv6.hh

	//static_assert(sizeof(IPv6) == 4 * sizeof(uint32_t));
	static_assert(sizeof(IPv6) == 4 * sizeof(uint32_t), "");

[root@localhost quagga]# gedit ./xpimd/xorp/libxorp/ipvx.cc ./xpimd/xorp/libxorp/selector.cc ./xpimd/xorp/libproto/packet.hh
	//static_assert(*);
	static_assert(*, "");

[root@localhost quagga]# gedit ./xpimd/xorp/libxorp/utility.h
//#define UNUSED(var)	static_assert(sizeof(var) != 0)
#define UNUSED(var)	static_assert(sizeof(var) != 0, "")

[root@localhost quagga]# gedit ./xpimd/xorp/libxorp/ipv6.cc
    //static_assert(sizeof(_addr) == sizeof(tmp_addr));
    static_assert(sizeof(_addr) == sizeof(tmp_addr), "");
-------------------------------------------------
/opt/android-on-linux/android-ndk-r12/sources/cxx-stl/llvm-libc++/libcxx/include/__config:598:0: note: this is the location of the previous definition
 #define static_assert(__b, __m) \
-------------------------------------------------


make -j4


-------------------------------------------------
xorp/pim/pim_mrt_task.cc:185:14: error: ambiguous overload for 'operator!=' (operand types are 'std::__ndk1::list<PimMreTask*>::reverse_iterator {aka std::__ndk1::reverse_iterator<std::__ndk1::__list_iterator<PimMreTask*, void*> >}' and 'std::__ndk1::list<PimMreTask*>::reverse_iterator {aka std::__ndk1::reverse_iterator<std::__ndk1::__list_iterator<PimMreTask*, void*> >}')
     if (iter != pim_mre_task_list().rend()) {
-------------------------------------------------
gedit ./xpimd/xorp/pim/pim_mrt_task.cc				// four places
-------------------------------------------------
    //if (iter != pim_mre_task_list().rend()) {
    if (!(iter == pim_mre_task_list().rend())) {
-------------------------------------------------


make -j4


-------------------------------------------------
xorp/pim/pim_vif.cc:632:21: error: aggregate 'PimVif::pim_send(const IPvX&, const IPvX&, uint8_t, buffer_t*, std::__ndk1::string&)::ip6_hdr ip6_header' has incomplete type and cannot be defined
      struct ip6_hdr ip6_header;
-------------------------------------------------
gedit ./xpimd/xorp/pim/pim_vif.cc
-------------------------------------------------
			// add the below line
#include <netinet/ip6.h>
-------------------------------------------------


make -j4

-------------------------------------------------
/opt/android-on-linux/android-ndk-r12/toolchains/x86_64-4.9/prebuilt/linux-x86_64/bin/../lib/gcc/x86_64-linux-android/4.9.x/../../../../x86_64-linux-android/bin/ld: error: ../lib/.libs/libzebra.a(thread.o): multiple definition of 'thread_timer_remain_second'
/opt/android-on-linux/android-ndk-r12/toolchains/x86_64-4.9/prebuilt/linux-x86_64/bin/../lib/gcc/x86_64-linux-android/4.9.x/../../../../x86_64-linux-android/bin/ld: xpimd-zebra_thread.o: previous definition here
/opt/android-on-linux/android-ndk-r12/toolchains/x86_64-4.9/prebuilt/linux-x86_64/bin/../lib/gcc/x86_64-linux-android/4.9.x/../../../../x86_64-linux-android/bin/ld: error: ../lib/.libs/libzebra.a(thread.o): multiple definition of 'funcname_thread_add_read'
/opt/android-on-linux/android-ndk-r12/toolchains/x86_64-4.9/prebuilt/linux-x86_64/bin/../lib/gcc/x86_64-linux-android/4.9.x/../../../../x86_64-linux-android/bin/ld: xpimd-zebra_thread.o: previous definition here
-------------------------------------------------
gedit xpimd/zebra_thread.hh xpimd/zebra_thread.cc
-------------------------------------------------
funcname_  -->  zt_					// 7 locations
thread_  -->  zt_thread_				// 6 locations
-------------------------------------------------


make -j4
make install


# 至此，编译成功


-------------------------------------------------
rm /opt/android-on-linux/quagga/out -rf

#// rm /opt/android-on-linux/quagga/out -rf
#// ./bootstrap.sh 
#// make clean
-------------------------------------------------


cd /opt/android-on-linux/quagga/

[root@localhost quagga]# 
cp out/etc/zebra.conf.sample out/etc/zebra.conf
cp out/etc/ospf6d.conf.sample out/etc/ospf6d.conf

------------------------------------------------- 

mkdir /opt/android-x86/tmp-iso-can-del/fep-lib-exe

cd /opt/android-on-linux/quagga
/bin/cp out/etc/zebra.conf /opt/android-x86/tmp-iso-can-del/fep-lib-exe/
/bin/cp out/etc/ospf6d.conf /opt/android-x86/tmp-iso-can-del/fep-lib-exe/
/bin/cp -r out/sbin/ /opt/android-x86/tmp-iso-can-del/fep-lib-exe/
/bin/cp out/lib/libzebra.so /opt/android-x86/tmp-iso-can-del/fep-lib-exe/
/bin/cp out/lib/libospf.so /opt/android-x86/tmp-iso-can-del/fep-lib-exe/
/bin/cp out/lib/libospfapiclient.so /opt/android-x86/tmp-iso-can-del/fep-lib-exe/

/bin/cp /opt/android-on-linux/android-ndk-r14b/sources/cxx-stl/stlport/libs/x86_64/libstlport_shared.so /opt/android-x86/tmp-iso-can-del/fep-lib-exe/
/bin/cp /opt/android-on-linux/android-ndk-r14b/sources/cxx-stl/llvm-libc++/libs/x86_64/libc++_shared.so /opt/android-x86/tmp-iso-can-del/fep-lib-exe/
/bin/cp /opt/tools/busybox/busybox-x86_64 /opt/android-x86/tmp-iso-can-del/fep-lib-exe/
/bin/cp /opt/android-x86/curl-7.50.0/out/bin/curl /opt/android-x86/tmp-iso-can-del/fep-lib-exe/
/bin/cp /opt/android-x86/curl-7.50.0/out/lib/libcurl.so /opt/android-x86/tmp-iso-can-del/fep-lib-exe/

scp -r /opt/android-x86/tmp-iso-can-del/fep-lib-exe/ 10.109.253.80:/opt/android-x86/tmp-iso-can-del/
scp -r /opt/android-x86/tmp-iso-can-del/fep-lib-exe/* 10.109.253.80:/opt/android-x86/tmp-iso-can-del/fep-lib-exe/

------------------------------------------------------------------------
So far, All is OK
------------------------------------------------------------------------



