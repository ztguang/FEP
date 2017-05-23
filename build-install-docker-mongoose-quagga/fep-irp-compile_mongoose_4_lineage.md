#
# This manual is released under GNU GPL v2,v3
# Author: Tongguang Zhang
# Date: 2017-05-23
#

[root@localhost mongoose-android-x86]# pwd
/opt/android-on-linux/mongoose/mongoose-android-x86

[root@localhost mongoose-android-x86]# ls
CONTRIBUTING.md  docs  examples  jni  LICENSE  mongoose.c  mongoose.h  README.md

[root@localhost mongoose-android-x86]# gedit examples/examples.mk

#----------------------------------------------------------

NDK_HOME = /opt/android-on-linux/android-ndk-r14b
TOOLCHAIN_HOME = $(NDK_HOME)/toolchains/x86_64-4.9/prebuilt/linux-x86_64
CROSS_COMPILE = $(TOOLCHAIN_HOME)/bin/x86_64-linux-android-
SYSROOT = $(NDK_HOME)/platforms/android-24/arch-x86_64
CC = $(CROSS_COMPILE)gcc
NDK_LIB = $(SYSROOT)/usr/lib64

CFLAGS += -g -W -fPIE -Wall -I../.. -Wno-unused-function $(CFLAGS_EXTRA) $(MODULE_CFLAGS)

INCDIRS = -I$(SYSROOT)/usr/include
LDFLAGS = --sysroot=$(SYSROOT) -L$(NDK_LIB)
LDFLAGS += -Wl,-rpath-link=$(SYSROOT)/usr/lib64
LDFLAGS += -ldl -fPIE -pie

SOURCES = $(PROG).c ../../mongoose.c

all: $(PROG)

ifeq ($(OS), Windows_NT)
# TODO(alashkin): enable SSL in Windows
CFLAGS += -lws2_32
else
ifeq ($(SSL_LIB),openssl)
CFLAGS += -DMG_ENABLE_SSL -lssl -lcrypto
else ifeq ($(SSL_LIB), krypton)
CFLAGS += -DMG_ENABLE_SSL -DMG_DISABLE_PFS ../../../krypton/krypton.c
endif
# CFLAGS += -lpthread
CFLAGS += 
endif


ifeq ($(JS), yes)
	V7_PATH = ../../deps/v7
	CFLAGS_EXTRA += -DMG_ENABLE_JAVASCRIPT -I $(V7_PATH) $(V7_PATH)/v7.c
endif

$(PROG): $(SOURCES)
	$(CC) $(SOURCES) -o $@ $(CFLAGS) $(INCDIRS) $(LDFLAGS)

$(PROG).exe: $(SOURCES)
	cl $(SOURCES) /I../.. /MD /Fe$@

clean:
	rm -rf *.gc* *.dSYM *.exe *.obj *.o a.out $(PROG)
#----------------------------------------------------------


[root@localhost mongoose-android-x86]# gedit examples/simplest_web_server/simplest_web_server.c

	//static const char *s_http_port = "8000";
	static const char *s_http_port = "80";

[root@localhost mongoose-android-x86]# gedit examples/websocket_chat/index.html

	//var ws = new WebSocket('ws://' + location.host + '/ws');
	var ws = new WebSocket('ws://' + location.host + ':8000');

[root@localhost mongoose-android-x86]# gedit examples/websocket_chat/websocket_chat.c

	//if (c == nc) continue; /* Don't send to the sender. */


#---------------------------------------------------

[root@localhost mongoose-android-x86]# cd examples/websocket_chat

[root@localhost websocket_chat]# make clean; make
[root@localhost websocket_chat]# cd ../simplest_web_server/
[root@localhost simplest_web_server]# make clean; make

[root@localhost simplest_web_server]# cd ../../examples/
[root@localhost examples]# mkdir /opt/android-x86/tmp-iso-can-del/fep-lib-exe/webserver
[root@localhost examples]# 

/bin/cp simplest_web_server/simplest_web_server /opt/android-x86/tmp-iso-can-del/fep-lib-exe/webserver/
/bin/cp websocket_chat/websocket_chat /opt/android-x86/tmp-iso-can-del/fep-lib-exe/webserver/

# /bin/cp websocket_chat/index.html /opt/android-x86/tmp-iso-can-del/fep-lib-exe/webserver/
cp /opt/share-vm/fedora23server-share/webserver/index.html /opt/android-x86/tmp-iso-can-del/fep-lib-exe/webserver/

[root@localhost examples]# adb push /opt/android-x86/tmp-iso-can-del/fep-lib-exe/webserver /system/xbin/quagga/

[root@localhost examples]# adb shell

# ./simplest_web_server &
# ./websocket_chat &

http://localhost

------------------------------------
All is OK
------------------------------------


