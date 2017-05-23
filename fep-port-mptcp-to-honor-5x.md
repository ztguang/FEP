#
# This manual is released under GNU GPL v2,v3
# Author: Tongguang Zhang
# Date: 2017-05-23
#

================================================================================
mptcp-be-ported-to-lineage-14.1-kiwi-on-VB
================================================================================

***********************************************************
step 1: in PC, prepare source codes
***********************************************************

mkdir /opt/android-x86/lineage-14.1-kiwi-on-VB
cd /opt/android-x86/lineage-14.1-kiwi-on-VB

[root@localhost lineage-14.1-kiwi-on-VB]# 

// download mptcp from  https://github.com/multipath-tcp/mptcp
// then unzip

[root@localhost lineage-14.1-kiwi-on-VB]# ls
kernel  mptcp-mptcp_v0.90  mptcp-mptcp_v0.90.zip

[root@localhost lineage-14.1-kiwi-on-VB]# mv mptcp-mptcp_v0.90 mptcp_v0.90


========================================================= // look MPTCP - begin

[root@localhost lineage-14.1-kiwi-on-VB]# cd mptcp_v0.90/
[root@localhost mptcp_v0.90]# find . -name mptcp*
./include/net/mptcp.h
./include/net/mptcp_v4.h
./include/net/mptcp_v6.h
./include/net/netns/mptcp.h
./net/mptcp
./net/mptcp/*
========================================================= // look MPTCP - end


========================================================= // copy MPTCP - begin

[root@localhost lineage-14.1-kiwi-on-VB]# pwd
/opt/android-x86/lineage-14.1-kiwi-on-VB

[root@localhost lineage-14.1-kiwi-on-VB]# 

/bin/cp -r mptcp_v0.90/net/mptcp/ kernel/net/
/bin/cp mptcp_v0.90/include/net/mptcp.h kernel/include/net/
/bin/cp mptcp_v0.90/include/net/mptcp_v4.h kernel/include/net/
/bin/cp mptcp_v0.90/include/net/mptcp_v6.h kernel/include/net/
/bin/cp mptcp_v0.90/include/net/netns/mptcp.h kernel/include/net/netns/

========================================================= // copy MPTCP - end


***********************************************************
step 2: in PC, modify source codes
***********************************************************


========================================================= // find files which should be modified - begin

[root@localhost lineage-14.1-kiwi-on-VB]# cd mptcp_v0.90/

drivers/infiniband/hw/cxgb4/cm.c
include/linux/ipv6.h
include/linux/tcp.h
include/net/inet6_connection_sock.h
include/net/inet_common.h
include/net/inet_connection_sock.h
include/net/inet_sock.h
include/net/net_namespace.h
include/net/request_sock.h
include/net/sock.h
include/net/tcp.h
include/net/transp_v6.h
include/uapi/linux/if.h
include/uapi/linux/tcp.h
net/Kconfig
net/Makefile
net/core/dev.c
net/core/request_sock.c
net/core/skbuff.c
net/core/sock.c
net/ipv4/Kconfig
net/ipv4/af_inet.c
net/ipv4/inet_connection_sock.c
net/ipv4/ip_sockglue.c
net/ipv4/syncookies.c
net/ipv4/tcp.c
net/ipv4/tcp_fastopen.c
net/ipv4/tcp_input.c
net/ipv4/tcp_ipv4.c
net/ipv4/tcp_minisocks.c
net/ipv4/tcp_output.c
net/ipv4/tcp_timer.c
net/ipv6/addrconf.c
net/ipv6/af_inet6.c
net/ipv6/inet6_connection_sock.c
net/ipv6/ipv6_sockglue.c
net/ipv6/syncookies.c
net/ipv6/tcp_ipv6.c
========================================================= // find files which should be modified - end


========================================================= // modify source codes - begin

-------------------------------------------------------------------
gedit kernel/drivers/infiniband/hw/cxgb4/cm.c
-------------------------------------------------------------------
//ztg alter
//	tcp_parse_options(skb, &tmp_opt, 0, NULL);
	tcp_parse_options(skb, &tmp_opt, NULL, 0, NULL);

-------------------------------------------------------------------

gedit kernel/include/linux/ipv6.h

-------------------------------------------------------------------
gedit kernel/include/linux/tcp.h
-------------------------------------------------------------------
//ztg del
//#ifdef CONFIG_TCP_MD5SIG
	/* Only used by TCP MD5 Signature so far. */
	const struct tcp_request_sock_ops *af_specific;
//ztg del
//#endif
-------------------------------------------------------------------

gedit kernel/include/net/inet6_connection_sock.h
gedit kernel/include/net/inet_common.h
gedit kernel/include/net/inet_connection_sock.h
gedit kernel/include/net/inet_sock.h
gedit kernel/include/net/net_namespace.h
gedit kernel/include/net/request_sock.h
gedit kernel/include/net/sock.h

-------------------------------------------------------------------
gedit kernel/include/net/tcp.h
-------------------------------------------------------------------
//ztg add
//---------
extern void tcp_openreq_init_rwin(struct request_sock *req,
				  struct sock *sk, struct dst_entry *dst);
//---------
extern void tcp_enter_memory_pressure(struct sock *sk);
---------------------------------------
//ztg alter
//void tcp_cwnd_validate(struct sock *sk, bool is_cwnd_limited);
void tcp_cwnd_validate(struct sock *sk);
---------------------------------------
//ztg alter
//	void (*cwnd_validate)(struct sock *sk, bool is_cwnd_limited);
	void (*cwnd_validate)(struct sock *sk);
---------------------------------------
//ztg del
/*
static inline void tcp_minshall_update(struct tcp_sock *tp, unsigned int mss,
				       const struct sk_buff *skb)
{
	if (skb->len < mss)
		tp->snd_sml = TCP_SKB_CB(skb)->end_seq;
}
*/


---------------------------------------
int tcp_fastopen_reset_cipher(void *key, unsigned int len);
//ztg add
//--------------------------------------------------------------------
bool tcp_try_fastopen(struct sock *sk, struct sk_buff *skb,
		      struct request_sock *req,
		      struct tcp_fastopen_cookie *foc,
		      struct dst_entry *dst);
//--------------------------------------------------------------------
---------------------------------------
int tcp_v6_send_synack(struct sock *sk, struct dst_entry *dst,
//ztg alter
//		       struct flowi *fl, struct request_sock *req,
		       struct flowi6 *fl6, struct request_sock *req,
//ztg alter
//		       u16 queue_mapping, struct tcp_fastopen_cookie *foc);
		       u16 queue_mapping);
---------------------------------------


-------------------------------------------------------------------


gedit kernel/include/net/transp_v6.h
gedit kernel/include/uapi/linux/if.h
gedit kernel/include/uapi/linux/tcp.h
gedit kernel/net/Kconfig
gedit kernel/net/Makefile
gedit kernel/net/core/dev.c

-------------------------------------------------------------------
gedit kernel/net/core/request_sock.c
------------------------------------------------------------------- use
int reqsk_queue_alloc(struct request_sock_queue *queue,
//ztg alter
//		      unsigned int nr_table_entries)
		      unsigned int nr_table_entries, gfp_t flags)
{
	size_t lopt_size = sizeof(struct listen_sock);
	struct listen_sock *lopt;

	nr_table_entries = min_t(u32, nr_table_entries, sysctl_max_syn_backlog);
	nr_table_entries = max_t(u32, nr_table_entries, 8);
	nr_table_entries = roundup_pow_of_two(nr_table_entries + 1);
	lopt_size += nr_table_entries * sizeof(struct request_sock *);
	if (lopt_size > PAGE_SIZE)
//ztg alter
//		lopt = vzalloc(lopt_size);
		lopt = __vmalloc(lopt_size, flags | __GFP_HIGHMEM | __GFP_ZERO, PAGE_KERNEL);
	else
//ztg alter
//		lopt = kzalloc(lopt_size, GFP_KERNEL);
		lopt = kzalloc(lopt_size, flags | __GFP_NOWARN | __GFP_NORETRY);
	if (lopt == NULL)
		return -ENOMEM;
}
-------------------------------------------------------------------


gedit kernel/net/core/skbuff.c
gedit kernel/net/core/sock.c
gedit kernel/net/ipv4/Kconfig
gedit kernel/net/ipv4/af_inet.c
gedit kernel/net/ipv4/inet_connection_sock.c


-------------------------------------------------------------------
gedit kernel/net/ipv4/ip_sockglue.c

-------------------------------------------------------------------
#include <net/ip_fib.h>

//ztg add
#include <net/mptcp.h>
---------------------------------------
		if (inet->tos != val) {
			inet->tos = val;
			sk->sk_priority = rt_tos2priority(val);
			sk_dst_reset(sk);
//ztg add
//--------------------------------------------------------------------
			/* Update TOS on mptcp subflow */
			if (is_meta_sk(sk)) {
				struct sock *sk_it;
				mptcp_for_each_sk(tcp_sk(sk)->mpcb, sk_it) {
					if (inet_sk(sk_it)->tos != inet_sk(sk)->tos) {
						inet_sk(sk_it)->tos = inet_sk(sk)->tos;
						sk_it->sk_priority = sk->sk_priority;
						sk_dst_reset(sk_it);
					}
				}
			}
//--------------------------------------------------------------------
		}
		break;
	case IP_TTL:
-------------------------------------------------------------------


gedit kernel/net/ipv4/syncookies.c
gedit kernel/net/ipv4/tcp.c


-------------------------------------------------------------------
gedit kernel/net/ipv4/tcp_fastopen.c
-------------------------------------------------------------------
static bool tcp_fastopen_create_child()
//ztg alter
//	sk->sk_data_ready(sk);
	sk->sk_data_ready(sk, 0);

static bool tcp_fastopen_queue_check(struct sock *sk)
bool tcp_try_fastopen()

-------------------------------------------------------------------


-------------------------------------------------------------------
gedit kernel/net/ipv4/tcp_input.c
-------------------------------------------------------------------

-------------------------------------------- no use
在 int tcp_rcv_state_process(struct sock *sk, struct sk_buff *skb,
的前面添加 static void tcp_synack_rtt_meas(struct sock *sk, const u32 synack_stamp){}
//ztg alter
//		tcp_ack_update_rtt(sk, FLAG_SYN_ACKED, seq_rtt_us, -1L);
		tcp_ack_update_rtt(sk, FLAG_SYN_ACKED, seq_rtt_us);
--------------------------------------------

-------------------------------------------------------------------
//ztg add
//--------------------------------------------------------------------
static inline void pr_drop_req(struct request_sock *req, __u16 port, int family)
{ }

static void tcp_ecn_create_request(struct request_sock *req,
                                   const struct sk_buff *skb,
                                   const struct sock *listen_sk)
{ }

int tcp_conn_request(struct request_sock_ops *rsk_ops,
                     const struct tcp_request_sock_ops *af_ops,
                     struct sock *sk, struct sk_buff *skb)
{
//ztg alter
//	tcp_openreq_init(req, &tmp_opt, skb, sk);
	tcp_openreq_init(req, &tmp_opt, skb);
//ztg alter
//			    !tcp_peer_is_proven(req, dst, true,
//						tmp_opt.saw_tstamp)) {
			    !tcp_peer_is_proven(req, dst, true)) {
//ztg alter
//			 !tcp_peer_is_proven(req, dst, false,
//					     tmp_opt.saw_tstamp)) {
			 !tcp_peer_is_proven(req, dst, false)) {
//--------------------------------------------------------------------

}


//ztg alter
//void tcp_parse_options(const struct sk_buff *skb,
//		       struct tcp_options_received *opt_rx, int estab,
//		       struct tcp_fastopen_cookie *foc)
//---------------------
void tcp_parse_options(const struct sk_buff *skb,
		       struct tcp_options_received *opt_rx,
		       struct mptcp_options_received *mopt,
		       int estab, struct tcp_fastopen_cookie *foc)
//---------------------
-------------------------------------------------------------------


-------------------------------------------------------------------
gedit kernel/net/ipv4/tcp_ipv4.c
-------------------------------------------------------------------

------------------------------------------
//ztg alter
//int tcp_v4_conn_request(struct sock *sk, struct sk_buff *skb)
static int tcp_v4_conn_request_orig(struct sock *sk, struct sk_buff *skb)
{
	int do_fastopen;

//ztg add
	if(!sk) return 0;
}
//ztg del
//EXPORT_SYMBOL(tcp_v4_conn_request);
------------------------------------------
//ztg add
//--------------------------------------------------------------------
int tcp_v4_conn_request(struct sock *sk, struct sk_buff *skb)
{
//ztg add
	tcp_v4_conn_request_orig(NULL, NULL);	// no effection
...
}
EXPORT_SYMBOL(tcp_v4_conn_request);
//--------------------------------------------------------------------

------------------------------------------------------------------- 
-static void tcp_v4_init_req(struct request_sock *req, struct sock *sk,
-			    struct sk_buff *skb)
+static int tcp_v4_init_req(struct request_sock *req, struct sock *sk,
+			   struct sk_buff *skb, bool want_cookie)
 {
 	struct inet_request_sock *ireq = inet_rsk(req);
 
@@ -1229,6 +1265,8 @@ static void tcp_v4_init_req(struct request_sock *req, struct sock *sk,
 	ireq->ir_rmt_addr = ip_hdr(skb)->saddr;
 	ireq->no_srccheck = inet_sk(sk)->transparent;
 	ireq->opt = tcp_v4_save_options(skb);
+
+	return 0;
 }
 
 static struct dst_entry *tcp_v4_route_req(struct sock *sk, struct flowi *fl,
-------------------------------------------------------------------


-------------------------------------------------------------------
gedit kernel/net/ipv4/tcp_minisocks.c
-------------------------------------------------------------------
tcp_twsk_destructor() 函数后面 添加 void tcp_openreq_init_rwin(){}

-------------------------------------------------------------------


-------------------------------------------------------------------
gedit kernel/net/ipv4/tcp_output.c
-------------------------------------------------------------------
-static void tcp_cwnd_validate(struct sock *sk, bool is_cwnd_limited)
+void tcp_cwnd_validate(struct sock *sk, bool is_cwnd_limited)
-------------------------------------------------------------------
//ztg alter
//	tcp_select_initial_window(tcp_full_space(sk),
	tp->ops->select_initial_window(tcp_full_space(sk),
//ztg alter
//				  dst_metric(dst, RTAX_INITRWND));
				       dst_metric(dst, RTAX_INITRWND), sk);
-------------------------------------------------------------------

//ztg alter
//	if (tcp_nagle_check(partial != 0, tp, nonagle))
	if (tcp_nagle_check(tp, skb, tcp_current_mss(sk), nonagle))
-------------------------------------------------------------------

-------------------------------------------------------------------
		if (tso_segs > 1 && !tcp_urg_mode(tp))
			limit = tcp_mss_split_point(sk, skb, mss_now,
						    min_t(unsigned int,
							  cwnd_quota,
//ztg alter
//							  sk->sk_gso_max_segs));
//--------
							  sk->sk_gso_max_segs),
						    nonagle);
//--------
------------------------------------------------------------------- 
-static void tcp_minshall_update(struct tcp_sock *tp, unsigned int mss_now,
-				const struct sk_buff *skb)
+void tcp_minshall_update(struct tcp_sock *tp, unsigned int mss_now,
+			 const struct sk_buff *skb)
 {
 	if (skb->len < tcp_skb_pcount(skb) * mss_now)
 		tp->snd_sml = TCP_SKB_CB(skb)->end_seq;

-------------------------------------------------------------------


-------------------------------------------------------------------
gedit kernel/net/ipv4/tcp_timer.c
gedit kernel/net/ipv6/addrconf.c
gedit kernel/net/ipv6/af_inet6.c
gedit kernel/net/ipv6/inet6_connection_sock.c
gedit kernel/net/ipv6/ipv6_sockglue.c
gedit kernel/net/ipv6/syncookies.c
-------------------------------------------------------------------
 	ret = NULL;
-	req = inet_reqsk_alloc(&tcp6_request_sock_ops);
+#ifdef CONFIG_MPTCP
+	if (mopt.saw_mpc)
+		req = inet_reqsk_alloc(&mptcp6_request_sock_ops);
+	else
+#endif
+		req = inet_reqsk_alloc(&tcp6_request_sock_ops);

-------------------------------------------------------------------


-------------------------------------------------------------------
gedit kernel/net/ipv6/tcp_ipv6.c
-------------------------------------------------------------------

------------------------------------------
//ztg alter
//int tcp_v6_conn_request(struct sock *sk, struct sk_buff *skb)
static int tcp_v6_conn_request_orig(struct sock *sk, struct sk_buff *skb)
{
	bool want_cookie = false;
//ztg add
	if(!sk) return 0;
}
------------------------------------------
//ztg add
//--------------------------------------------------------------------
int tcp_v6_conn_request(struct sock *sk, struct sk_buff *skb)
{
//ztg add
	tcp_v4_conn_request_orig(NULL, NULL);	// no effection
...
}
EXPORT_SYMBOL(tcp_v6_conn_request);
//--------------------------------------------------------------------

------------------------------------------
//ztg alter
//		       struct flowi *fl,
		       struct flowi6 *fl6,
------------------------------------------

-------------------------------------------------------------------
-static void tcp_v6_init_req(struct request_sock *req, struct sock *sk,
-			    struct sk_buff *skb)
+static int tcp_v6_init_req(struct request_sock *req, struct sock *sk,
+			   struct sk_buff *skb, bool want_cookie)
 { }
 
 static struct dst_entry *tcp_v6_route_req(struct sock *sk, struct flowi *fl,
-------------------------------------------------------------------
 static void tcp_v6_send_response(struct sock *sk, struct sk_buff *skb, u32 seq,
-				 u32 ack, u32 win, u32 tsval, u32 tsecr,
+				 u32 ack, u32 data_ack, u32 win, u32 tsval, u32 tsecr,
 				 int oif, struct tcp_md5sig_key *key, int rst,
-				 u8 tclass, u32 label)
+				 u8 tclass, u32 label, int mptcp)
-------------------------------------------------------------------

========================================================= // modify source codes - end



--------------------------------- no use
[root@localhost android_x86_64]# pwd
/opt/android-x86/lineage-14.1-kiwi-on-VB/kernel/generic/android_x86_64

[root@localhost android_x86_64]# 

mkdir -p /root/opt/android-x86/lineage-14.1-kiwi-on-VB/kernel/drivers/infiniband/hw/cxgb4/
cp drivers/infiniband/hw/cxgb4/cm.c /root/opt/android-x86/lineage-14.1-kiwi-on-VB/kernel/drivers/infiniband/hw/cxgb4/

mkdir -p /root/opt/android-x86/lineage-14.1-kiwi-on-VB/kernel/arch/
cp arch/Kconfig /root/opt/android-x86/lineage-14.1-kiwi-on-VB/kernel/arch/
---------------------------------



***********************************************************
step 3: get altered files which be put into /root/opt/android-x86/lineage-14.1-kiwi-on-VB/kernel/
***********************************************************

[root@localhost lineage-14.1-kiwi-on-VB]# pwd
/opt/android-x86/lineage-14.1-kiwi-on-VB

[root@localhost lineage-14.1-kiwi-on-VB]# 

./find-alter-files.sh kernel/drivers

./find-alter-files.sh kernel/include
./find-alter-files.sh kernel/net

cp -a timestamp.txt timestamp.txt.all.modify
touch timestamp.txt


***********************************************************
copy files to IBM Server
***********************************************************

scp -r /root/opt/android-x86/lineage-14.1-kiwi-on-VB/kernel/* 10.109.253.80:/opt/android-x86/lineage-14.1-kiwi-on-VB/kernel/



***********************************************************
step 5: compile Android-x86 in IBM Server
***********************************************************

[root@localhost lineage-14.1-kiwi-on-VB]# pwd
/opt/android-x86/lineage-14.1-kiwi-on-VB

-------------------------------------------------------------------
cd /opt/android-x86/lineage-14.1-kiwi-on-VB

. build/envsetup.sh
lunch cm_android_x86_64-userdebug
m -j32 iso_img
-----------------------------------
rm out/target/product/android_x86_64/obj/kernel/ -rf
cd kernel/; make mrproper; cd -
m -j32 iso_img
-------------------------------------------------------------------


==============================  begin

[root@localhost lineage-14.1-kiwi-on-VB]# pwd
/opt/android-x86/lineage-14.1-kiwi-on-VB

[root@localhost lineage-14.1-kiwi-on-VB]# 

rm kernel/net/mptcp -rf
rm /root/opt/android-x86/lineage-14.1-kiwi-on-VB/kernel/net/mptcp/ -rf


gedit kernel/net/mptcp/*

gedit kernel/include/net/mptcp.h
gedit kernel/include/net/mptcp_v4.h
gedit kernel/include/net/mptcp_v6.h
gedit kernel/include/net/netns/mptcp.h

-------------------------------------------------------------------
./find-alter-files.sh kernel/drivers

./find-alter-files.sh kernel/include
./find-alter-files.sh kernel/net

scp -r /root/opt/android-x86/lineage-14.1-kiwi-on-VB/kernel/* 10.109.253.80:/opt/android-x86/lineage-14.1-kiwi-on-VB/kernel/

touch timestamp.txt
-------------------------------------------------------------------

============================== end


============ 编译错误，修改源代码 - begin

---------------------------------
/opt/android-x86/lineage-14.1-kiwi-on-VB/kernel/include/net/tcp.h:1055:36: error: 'TCP_CONG_NEEDS_ECN' undeclared (first use in this function)
---------------------------------
gedit kernel/net/ipv4/tcp_input.c
---------------------------------
static void tcp_ecn_create_request(struct request_sock *req,
				   const struct sk_buff *skb,
				   const struct sock *listen_sk)
{
...
/*										// del the below lines
	ect = !INET_ECN_is_not_ect(TCP_SKB_CB(skb)->ip_dsfield);
	need_ecn = tcp_ca_needs_ecn(listen_sk);

	if (!ect && !need_ecn && net->ipv4.sysctl_tcp_ecn)
		inet_rsk(req)->ecn_ok = 1;
	else if (ect && need_ecn)
		inet_rsk(req)->ecn_ok = 1;
*/
}
---------------------------------
gedit kernel/include/net/tcp.h
---------------------------------
//ztg del
/*
static inline bool tcp_ca_needs_ecn(const struct sock *sk)
{
	const struct inet_connection_sock *icsk = inet_csk(sk);

	return icsk->icsk_ca_ops->flags & TCP_CONG_NEEDS_ECN;
}
*/
---------------------------------


---------------------------------
/opt/android-x86/lineage-14.1-kiwi-on-VB/kernel/net/ipv4/tcp_output.c:1646:47: warning: passing argument 1 of 'tcp_current_mss' discards 'const' qualifier from pointer target type
error, forbidden warning: tcp_output.c:1646
---------------------------------
gedit kernel/net/ipv4/tcp_output.c
gedit kernel/include/net/tcp.h
---------------------------------
//ztg alter
//unsigned int tcp_mss_split_point(const struct sock *sk,
//				 const struct sk_buff *skb,
unsigned int tcp_mss_split_point(struct sock *sk,
				 struct sk_buff *skb,
---------------------------------

---------------------------------
/opt/android-x86/lineage-14.1-kiwi-on-VB/kernel/include/linux/stddef.h:8:14: warning: passing argument 4 of 'tcp_parse_options' makes integer from pointer without a cast
error, forbidden warning: stddef.h:8
---------------------------------
gedit kernel/net/ipv4/tcp_ipv4.c
---------------------------------
//ztg alter
//	tcp_parse_options(skb, &tmp_opt, 0, want_cookie ? NULL : &foc);
	tcp_parse_options(skb, &tmp_opt, NULL, 0, want_cookie ? NULL : &foc);
---------------------------------
gedit kernel/net/ipv6/tcp_ipv6.c
---------------------------------
//ztg alter
//	tcp_parse_options(skb, &tmp_opt, 0, NULL);
	tcp_parse_options(skb, &tmp_opt, NULL, 0, NULL);
---------------------------------

---------------------------------
/opt/android-x86/lineage-14.1-kiwi-on-VB/kernel/net/ipv6/tcp_ipv6.c:1263:2: error: implicit declaration of function 'tcp_conn_request' [-Werror=implicit-function-declaration]
---------------------------------
gedit kernel/include/net/tcp.h
---------------------------------
extern void tcp4_proc_exit(void);
#endif

//ztg add
//-----
int tcp_conn_request(struct request_sock_ops *rsk_ops,
		     const struct tcp_request_sock_ops *af_ops,
		     struct sock *sk, struct sk_buff *skb);
//-----
---------------------------------

---------------------------------
gedit kernel/net/mptcp/mptcp_ipv4.c
---------------------------------
//ztg alter
//	.rtx_syn_ack	=	tcp_rtx_synack,
	.rtx_syn_ack	=	tcp_v4_rtx_synack,
---------------------------------
gedit kernel/net/mptcp/mptcp_ipv6.c
---------------------------------
//ztg alter
//	.rtx_syn_ack	=	tcp_rtx_synack,
	.rtx_syn_ack	=	tcp_v6_rtx_synack,
---------------------------------
gedit kernel/net/ipv4/tcp_ipv4.c
---------------------------------
//ztg alter
//static int tcp_v4_rtx_synack(struct sock *sk, struct request_sock *req)
int tcp_v4_rtx_synack(struct sock *sk, struct request_sock *req)
---------------------------------
gedit kernel/net/ipv6/tcp_ipv6.c
---------------------------------
//ztg alter
//static int tcp_v6_rtx_synack(struct sock *sk, struct request_sock *req)
int tcp_v6_rtx_synack(struct sock *sk, struct request_sock *req)
---------------------------------
gedit kernel/include/net/tcp.h
---------------------------------
//ztg add
int tcp_v4_rtx_synack(struct sock *sk, struct request_sock *req);
void tcp_v4_reqsk_destructor(struct request_sock *req);

//ztg add
int tcp_v6_rtx_synack(struct sock *sk, struct request_sock *req);
void tcp_v6_reqsk_destructor(struct request_sock *req);
---------------------------------

---------------------------------
/opt/android-x86/lineage-14.1-kiwi-on-VB/kernel/net/ipv4/tcp_ipv4.c:979:41: warning: passing argument 3 of 'tcp_v4_send_synack' from incompatible pointer type
error, forbidden warning: tcp_ipv4.c:979
---------------------------------
gedit kernel/net/ipv4/tcp_ipv4.c
---------------------------------
static int tcp_v4_send_synack(struct sock *sk, struct dst_entry *dst,
			      struct request_sock *req,
			      u16 queue_mapping,
			      bool nocache)
---------------------------------
gedit kernel/net/ipv6/tcp_ipv6.c
--------------------------------- 
static int tcp_v6_send_synack(struct sock *sk, struct dst_entry *dst,
//int tcp_v6_send_synack(struct sock *sk, struct dst_entry *dst,
		      struct flowi6 *fl6,
		      struct request_sock *req,
		      u16 queue_mapping)
---------------------------------
gedit kernel/include/net/tcp.h
---------------------------------
//int tcp_v4_send_synack(struct sock *sk, struct dst_entry *dst,
//		       struct flowi *fl,
//		       struct request_sock *req,
//		       u16 queue_mapping,
//		       struct tcp_fastopen_cookie *foc);

//int tcp_v6_send_synack(struct sock *sk, struct dst_entry *dst,
//ztg alter
//		       struct flowi *fl, struct request_sock *req,
//		       struct flowi6 *fl6, struct request_sock *req,
//ztg alter
//		       u16 queue_mapping, struct tcp_fastopen_cookie *foc);
//		       u16 queue_mapping);
---------------------------------

---------------------------------
/opt/android-x86/lineage-14.1-kiwi-on-VB/kernel/net/ipv4/tcp_fastopen.c:285:30: warning: passing argument 1 of 'tcp_fastopen_cookie_gen' makes integer from pointer without a cast
error, forbidden warning: tcp_fastopen.c:285
---------------------------------
gedit kernel/net/ipv4/tcp_fastopen.c
---------------------------------
//ztg add
	struct iphdr *iph = ip_hdr(skb);
	struct tcp_fastopen_cookie valid_foc = { .len = -1 };

//ztg alter
//	if (tcp_fastopen_cookie_gen(req, skb, &valid_foc) &&
	if (tcp_fastopen_cookie_gen(iph->saddr, &valid_foc) &&
---------------------------------
//ztg alter
//void tcp_fastopen_cookie_gen(__be32 addr, struct tcp_fastopen_cookie *foc)
bool tcp_fastopen_cookie_gen(__be32 addr, struct tcp_fastopen_cookie *foc)
{
	__be32 peer_addr[4] = { addr, 0, 0, 0 };
	struct tcp_fastopen_context *ctx;
//ztg add
	bool ok = false;

	rcu_read_lock();
	ctx = rcu_dereference(tcp_fastopen_ctx);
	if (ctx) {
		crypto_cipher_encrypt_one(ctx->tfm,
					  foc->val,
					  (__u8 *)peer_addr);
		foc->len = TCP_FASTOPEN_COOKIE_SIZE;
//ztg add
		ok = true;
	}
	rcu_read_unlock();
//ztg add
	return ok;
}
---------------------------------
gedit kernel/include/net/tcp.h
---------------------------------
//ztg alter
//void tcp_fastopen_cookie_gen(__be32 addr, struct tcp_fastopen_cookie *foc);
bool tcp_fastopen_cookie_gen(__be32 addr, struct tcp_fastopen_cookie *foc);
---------------------------------

---------------------------------
net/built-in.o:activity_stats.c:function tcp_v4_conn_request: error: undefined reference to 'tcp_request_sock_ipv4_ops'
---------------------------------
gedit kernel/net/ipv4/tcp_ipv4.c
---------------------------------
//ztg alter
//#ifdef CONFIG_TCP_MD5SIG
//static const struct tcp_request_sock_ops tcp_request_sock_ipv4_ops = {
//	.md5_lookup	=	tcp_v4_reqsk_md5_lookup,
//	.calc_md5_hash	=	tcp_v4_md5_hash_skb,
//};
//#endif
//-------
const struct tcp_request_sock_ops tcp_request_sock_ipv4_ops = {
	.mss_clamp	=	TCP_MSS_DEFAULT,
#ifdef CONFIG_TCP_MD5SIG
	.md5_lookup	=	tcp_v4_reqsk_md5_lookup,
	.calc_md5_hash	=	tcp_v4_md5_hash_skb,
#endif
	.init_req	=	tcp_v4_init_req,
#ifdef CONFIG_SYN_COOKIES
	.cookie_init_seq =	cookie_v4_init_sequence,
#endif
	.route_req	=	tcp_v4_route_req,
	.init_seq	=	tcp_v4_init_sequence,
	.send_synack	=	tcp_v4_send_synack,
	.queue_hash_add =	inet_csk_reqsk_queue_hash_add,
};
//-------
---------------------------------
//ztg add
//-------

static void tcp_v4_init_req(struct request_sock *req, struct sock *sk,
			    struct sk_buff *skb, bool want_cookie)
{
	struct inet_request_sock *ireq = inet_rsk(req);

	ireq->ir_loc_addr = ip_hdr(skb)->daddr;
	ireq->ir_rmt_addr = ip_hdr(skb)->saddr;
	ireq->no_srccheck = inet_sk(sk)->transparent;
	ireq->opt = tcp_v4_save_options(skb);
}

static struct dst_entry *tcp_v4_route_req(struct sock *sk, struct flowi *fl,
					  const struct request_sock *req,
					  bool *strict)
{
	struct dst_entry *dst = inet_csk_route_req(sk, &fl->u.ip4, req);

	if (strict) {
		if (fl->u.ip4.daddr == inet_rsk(req)->ir_rmt_addr)
			*strict = true;
		else
			*strict = false;
	}

	return dst;
}
//-------

struct request_sock_ops tcp_request_sock_ops __read_mostly = {
---------------------------------

---------------------------------
net/built-in.o:activity_stats.c:function tcp_v6_conn_request: error: undefined reference to 'tcp_request_sock_ipv6_ops'
---------------------------------
gedit kernel/net/ipv6/tcp_ipv6.c
---------------------------------
//ztg alter
//#ifdef CONFIG_TCP_MD5SIG
//static const struct tcp_request_sock_ops tcp_request_sock_ipv6_ops = {
//	.md5_lookup	=	tcp_v6_reqsk_md5_lookup,
//	.calc_md5_hash	=	tcp_v6_md5_hash_skb,
//};
//#endif
//-------
const struct tcp_request_sock_ops tcp_request_sock_ipv6_ops = {
	.mss_clamp	=	IPV6_MIN_MTU - sizeof(struct tcphdr) -
				sizeof(struct ipv6hdr),
#ifdef CONFIG_TCP_MD5SIG
	.md5_lookup	=	tcp_v6_reqsk_md5_lookup,
	.calc_md5_hash	=	tcp_v6_md5_hash_skb,
#endif
	.init_req	=	tcp_v6_init_req,
#ifdef CONFIG_SYN_COOKIES
	.cookie_init_seq =	cookie_v6_init_sequence,
#endif
	.route_req	=	tcp_v6_route_req,
	.init_seq	=	tcp_v6_init_sequence,
	.send_synack	=	tcp_v6_send_synack,
	.queue_hash_add =	inet6_csk_reqsk_queue_hash_add,
};
//-------
---------------------------------
//ztg add
//-------
static void tcp_v6_init_req(struct request_sock *req, struct sock *sk,
			    struct sk_buff *skb)
{
	struct inet_request_sock *ireq = inet_rsk(req);
	struct ipv6_pinfo *np = inet6_sk(sk);

	ireq->ir_v6_rmt_addr = ipv6_hdr(skb)->saddr;
	ireq->ir_v6_loc_addr = ipv6_hdr(skb)->daddr;

	ireq->ir_iif = sk->sk_bound_dev_if;

	/* So that link locals have meaning */
	if (!sk->sk_bound_dev_if &&
	    ipv6_addr_type(&ireq->ir_v6_rmt_addr) & IPV6_ADDR_LINKLOCAL)
		ireq->ir_iif = tcp_v6_iif(skb);

	if (!TCP_SKB_CB(skb)->tcp_tw_isn &&
	    (ipv6_opt_accepted(sk, skb, &TCP_SKB_CB(skb)->header.h6) ||
	     np->rxopt.bits.rxinfo ||
	     np->rxopt.bits.rxoinfo || np->rxopt.bits.rxhlim ||
	     np->rxopt.bits.rxohlim || np->repflow)) {
		atomic_inc(&skb->users);
		ireq->pktopts = skb;
	}
}

static struct dst_entry *tcp_v6_route_req(struct sock *sk, struct flowi *fl,
					  const struct request_sock *req,
					  bool *strict)
{
	if (strict)
		*strict = true;
	return inet6_csk_route_req(sk, &fl->u.ip6, req);
}
//-------

struct request_sock_ops tcp6_request_sock_ops __read_mostly = {
---------------------------------

---------------------------------
/opt/android-x86/lineage-14.1-kiwi-on-VB/kernel/net/ipv6/tcp_ipv6.c:801:6: error: 'struct inet_request_sock' has no member named 'ir_v6_rmt_addr'

/opt/android-x86/lineage-14.1-kiwi-on-VB/kernel/net/ipv6/tcp_ipv6.c:802:6: error: 'struct inet_request_sock' has no member named 'ir_v6_loc_addr'

/opt/android-x86/lineage-14.1-kiwi-on-VB/kernel/net/ipv6/tcp_ipv6.c:804:6: error: 'struct inet_request_sock' has no member named 'ir_iif'
---------------------------------
gedit kernel/include/net/request_sock.h
---------------------------------
struct request_sock {
//ztg add
	struct sock_common		__req_common;
---------------------------------
gedit kernel/include/net/sock.h
---------------------------------
struct sock_common {

#ifdef CONFIG_NET_NS
	struct net	 	*skc_net;
#endif

//ztg add
//-------
#if IS_ENABLED(CONFIG_IPV6)
	struct in6_addr		skc_v6_daddr;
	struct in6_addr		skc_v6_rcv_saddr;
#endif
//-------
}
---------------------------------
gedit kernel/include/net/inet_sock.h
---------------------------------
struct inet_request_sock {
	struct request_sock	req;
//ztg add
//-------
#define ir_loc_addr		req.__req_common.skc_rcv_saddr
#define ir_rmt_addr		req.__req_common.skc_daddr
#define ir_num			req.__req_common.skc_num
#define ir_rmt_port		req.__req_common.skc_dport
#define ir_v6_rmt_addr		req.__req_common.skc_v6_daddr
#define ir_v6_loc_addr		req.__req_common.skc_v6_rcv_saddr
#define ir_iif			req.__req_common.skc_bound_dev_if
//-------

//ztg alter
//	struct ip_options_rcu	*opt;
//-------
	union {
		struct ip_options_rcu	*opt;
		struct sk_buff		*pktopts;
	};
//-------
};
---------------------------------

---------------------------------
/opt/android-x86/lineage-14.1-kiwi-on-VB/kernel/net/ipv6/tcp_ipv6.c:815:35: error: 'struct ipv6_pinfo' has no member named 'repflow'
---------------------------------
gedit kernel/include/linux/ipv6.h
---------------------------------
struct ipv6_pinfo {
	                        sndflow:1,
//ztg add
				repflow:1,
};
---------------------------------

---------------------------------
gedit kernel/include/net/tcp.h
---------------------------------
//ztg add
//-------
#if IS_ENABLED(CONFIG_IPV6)
/* This is the variant of inet6_iif() that must be used by TCP,
 * as TCP moves IP6CB into a different location in skb->cb[]
 */
static inline int tcp_v6_iif(const struct sk_buff *skb)
{
	return TCP_SKB_CB(skb)->header.h6.iif;
}
#endif
//-------

/* Due to TSO, an SKB can be composed of multiple actual
---------------------------------

---------------------------------
/opt/android-x86/lineage-14.1-kiwi-on-VB/kernel/net/ipv6/tcp_ipv6.c:812:7: error: too many arguments to function 'ipv6_opt_accepted'
---------------------------------
gedit kernel/net/ipv6/tcp_ipv6.c
---------------------------------
//ztg alter
//	    (ipv6_opt_accepted(sk, skb, &TCP_SKB_CB(skb)->header.h6) ||
	    (ipv6_opt_accepted(sk, skb) ||
---------------------------------

---------------------------------
/opt/android-x86/lineage-14.1-kiwi-on-VB/kernel/net/ipv4/tcp_ipv4.c:1437:2: warning: initialization from incompatible pointer type

/opt/android-x86/lineage-14.1-kiwi-on-VB/kernel/net/ipv6/tcp_ipv6.c:858:2: warning: initialization from incompatible pointer type
---------------------------------
gedit kernel/include/net/tcp.h
---------------------------------
//ztg alter
//	int (*init_req)(struct request_sock *req, struct sock *sk,
//			 struct sk_buff *skb, bool want_cookie);
	void (*init_req)(struct request_sock *req, struct sock *sk,
			 struct sk_buff *skb, bool want_cookie);
---------------------------------
gedit kernel/net/ipv4/tcp_input.c
---------------------------------
//ztg alter
//	if (af_ops->init_req(req, sk, skb, want_cookie))
	af_ops->init_req(req, sk, skb, want_cookie);
---------------------------------

---------------------------------
/opt/android-x86/lineage-14.1-kiwi-on-VB/kernel/net/ipv4/tcp_ipv4.c:1443:2: warning: initialization from incompatible pointer type
---------------------------------
gedit kernel/net/ipv4/tcp_ipv4.c
---------------------------------
//ztg alter
//-------
//static int tcp_v4_send_synack(struct sock *sk, struct dst_entry *dst,
//			      struct request_sock *req,
//			      u16 queue_mapping,
//			      bool nocache)
//-------
int tcp_v4_send_synack(struct sock *sk, struct dst_entry *dst,
		       struct flowi6 *fl,
		       struct request_sock *req,
		       u16 queue_mapping)
---------------------------------
//ztg alter
//static int tcp_v4_rtx_synack(struct sock *sk, struct request_sock *req)
int tcp_v4_rtx_synack(struct sock *sk, struct request_sock *req)
{
//ztg alter
//	int res = tcp_v4_send_synack(sk, NULL, req, 0, false);
	int res = tcp_v4_send_synack(sk, NULL, NULL, req, 0);
---------------------------------
gedit kernel/net/ipv4/tcp_input.c
---------------------------------
//ztg alter
//	err = af_ops->send_synack(sk, dst, &fl, req,
//				  skb_get_queue_mapping(skb), &foc);
	err = af_ops->send_synack(sk, dst, (struct flowi6 *)&fl, req, skb_get_queue_mapping(skb));
---------------------------------
gedit kernel/include/net/tcp.h
---------------------------------
//ztg alter
//	int (*send_synack)(struct sock *sk, struct dst_entry *dst,
//			   struct flowi *fl, struct request_sock *req,
//			   u16 queue_mapping, struct tcp_fastopen_cookie *foc);
//-------
	int (*send_synack)(struct sock *sk, struct dst_entry *dst,
			   struct flowi6 *fl, struct request_sock *req,
			   u16 queue_mapping);
//-------
---------------------------------

---------------------------------
/opt/android-x86/lineage-14.1-kiwi-on-VB/kernel/net/ipv6/tcp_ipv6.c:864:2: warning: initialization from incompatible pointer type
---------------------------------
gedit kernel/net/ipv6/tcp_ipv6.c
---------------------------------
//ztg alter
static int tcp_v6_send_synack(struct sock *sk, struct dst_entry *dst,
		      struct flowi6 *fl6,
		      struct request_sock *req,
		      u16 queue_mapping)
---------------------------------

---------------------------------
/opt/android-x86/lineage-14.1-kiwi-on-VB/kernel/net/ipv6/tcp_ipv6.c:608:4: error: implicit declaration of function 'ip6_flowlabel' [-Werror=implicit-function-declaration]
---------------------------------
gedit kernel/include/net/ipv6.h
---------------------------------
//ztg add
//-------
static inline __be32 ip6_flowlabel(const struct ipv6hdr *hdr)
{
	return *(__be32 *)hdr & IPV6_FLOWLABEL_MASK;
}
//-------
---------------------------------

---------------------------------
/opt/android-x86/lineage-14.1-kiwi-on-VB/kernel/net/ipv4/tcp_output.c:3210:9: error: 'struct sock' has no member named 'sk_v6_daddr'
---------------------------------
gedit kernel/include/net/sock.h
---------------------------------
struct sock {

}
---------------------------------


============ 编译错误，修改源代码 - end

================================================ 至此，成功编译，安装，能够访问互联网，但是，没有包含 MPTCP，下面 启用 MPTCP。



***********************************************************
step 5: 在 IBM Server，修改配置文件，使得 将 MPTCP 编译进内核
***********************************************************

---------------------------------------------
gedit kernel/net/Makefile
--------------------------------------------- use
obj-$(CONFIG_NET)		+= ipv6/
#//ztg add
obj-$(CONFIG_MPTCP)		+= mptcp/
---------------------------------------------

---------------------------------------------
gedit kernel/net/Kconfig
--------------------------------------------- use
source "net/netlabel/Kconfig"
#//ztg add
source "net/mptcp/Kconfig"
---------------------------------------------

---------------------------------------------
gedit kernel/net/mptcp/Kconfig
--------------------------------------------- use
config MPTCP
	default y							// add the line
---------------------------------------------


---------------------------------------------
[root@localhost lineage-14.1-kiwi-on-VB]# 

vim out/target/product/android_x86_64/obj/kernel/.config
---------------------------------------------

-------------------------------------------------------------------
rm out/target/product/android_x86_64/obj/kernel/ -rf
cd kernel/; make mrproper; cd -
m -j32 iso_img
-------------------------------------------------------------------


============ MPTCP 编译错误，修改源代码 - begin

---------------------------------
/opt/android-x86/lineage-14.1-kiwi-on-VB/kernel/net/mptcp/mptcp_ipv4.c:85:2: error: too many arguments to function 'tcp_request_sock_ipv4_ops.init_req'
---------------------------------
gedit kernel/net/ipv4/tcp_ipv4.c
---------------------------------
static void tcp_v4_init_req(struct request_sock *req, struct sock *sk,
			    struct sk_buff *skb, bool want_cookie)
---------------------------------
gedit kernel/net/ipv6/tcp_ipv6.c
---------------------------------
static void tcp_v6_init_req(struct request_sock *req, struct sock *sk,
			    struct sk_buff *skb, bool want_cookie)
---------------------------------
gedit kernel/include/net/tcp.h
---------------------------------
//ztg alter
//	int (*init_req)(struct request_sock *req, struct sock *sk,
//			 struct sk_buff *skb, bool want_cookie);
	void (*init_req)(struct request_sock *req, struct sock *sk,
			 struct sk_buff *skb, bool want_cookie);
---------------------------------

---------------------------------
/opt/android-x86/lineage-14.1-kiwi-on-VB/kernel/net/mptcp/mptcp_ipv4.c:466:2: error: unknown field 'mtu_reduced' specified in initializer
---------------------------------
gedit kernel/include/net/inet_connection_sock.h
---------------------------------
	int	    (*bind_conflict)(const struct sock *sk,
				     const struct inet_bind_bucket *tb, bool relax);
//ztg add
	void	    (*mtu_reduced)(struct sock *sk);
---------------------------------
gedit kernel/net/ipv4/tcp_ipv4.c
---------------------------------
	.compat_getsockopt = compat_ip_getsockopt,
#endif
//ztg add
	.mtu_reduced	   = tcp_v4_mtu_reduced,
---------------------------------
 
---------------------------------
/opt/android-x86/lineage-14.1-kiwi-on-VB/kernel/net/mptcp/mptcp_ctrl.c:508:5: error: implicit declaration of function 'sock_gen_put' [-Werror=implicit-function-declaration]
---------------------------------
gedit kernel/include/net/sock.h
---------------------------------
//ztg add
//-------
/* Generic version of sock_put(), dealing with all sockets
 * (TCP_TIMEWAIT, ESTABLISHED...)
 */
extern void sock_gen_put(struct sock *sk);
//-------

extern int sk_receive_skb(struct sock *sk, struct sk_buff *skb,
			  const int nested);
---------------------------------
gedit kernel/net/ipv4/inet_hashtables.c
---------------------------------
//ztg add
//-------
/* All sockets share common refcount, but have different destructors */
void sock_gen_put(struct sock *sk)
{
	if (!atomic_dec_and_test(&sk->sk_refcnt))
		return;

	if (sk->sk_state == TCP_TIME_WAIT)
		inet_twsk_free(inet_twsk(sk));
	else
		sk_free(sk);
}
EXPORT_SYMBOL_GPL(sock_gen_put);
//-------

struct sock *__inet_lookup_established(struct net *net,
---------------------------------
gedit kernel/net/ipv4/inet_timewait_sock.c
---------------------------------
//ztg alter
//static noinline void inet_twsk_free(struct inet_timewait_sock *tw)
void inet_twsk_free(struct inet_timewait_sock *tw)
---------------------------------

---------------------------------
/opt/android-x86/lineage-14.1-kiwi-on-VB/kernel/net/mptcp/mptcp_ctrl.c:1206:3: error: implicit declaration of function 'tcp_assign_congestion_control' [-Werror=implicit-function-declaration]
---------------------------------
gedit kernel/include/net/tcp.h
---------------------------------
//ztg add
extern void tcp_assign_congestion_control(struct sock *sk);
extern void tcp_init_congestion_control(struct sock *sk);
---------------------------------

---------------------------------
gedit kernel/net/ipv4/tcp_cong.c
---------------------------------
//ztg del
//-------
/* Assign choice of congestion control. */
/*
void tcp_init_congestion_control(struct sock *sk)
{
...
}
*/
//-------

//ztg add
//-------
/* Assign choice of congestion control. */
void tcp_assign_congestion_control(struct sock *sk)
{
	struct inet_connection_sock *icsk = inet_csk(sk);
	struct tcp_congestion_ops *ca;

	rcu_read_lock();
	list_for_each_entry_rcu(ca, &tcp_cong_list, list) {
		if (likely(try_module_get(ca->owner))) {
			icsk->icsk_ca_ops = ca;
			goto out;
		}
		/* Fallback to next available. The last really
		 * guaranteed fallback is Reno from this list.
		 */
	}
out:
	rcu_read_unlock();

	/* Clear out private data before diag gets it and
	 * the ca has not been initialized.
	 */
	if (ca->get_info)
		memset(icsk->icsk_ca_priv, 0, sizeof(icsk->icsk_ca_priv));
}

void tcp_init_congestion_control(struct sock *sk)
{
	const struct inet_connection_sock *icsk = inet_csk(sk);

	if (icsk->icsk_ca_ops->init)
		icsk->icsk_ca_ops->init(sk);
}
//-------
---------------------------------

---------------------------------
/opt/android-x86/lineage-14.1-kiwi-on-VB/kernel/net/mptcp/mptcp_ctrl.c:569:23: error: 'struct tcp_sock' has no member named 'srtt_us'
---------------------------------
sed -i "s/srtt_us/srtt/g" `grep "srtt_us" -rl ./kernel`
---------------------------------

---------------------------------
/opt/android-x86/lineage-14.1-kiwi-on-VB/kernel/net/mptcp/mptcp_ctrl.c:1083:12: error: 'struct sock' has no member named 'sk_ipv6only'
---------------------------------
gedit kernel/include/net/sock.h
---------------------------------
#define sk_reuseport		__sk_common.skc_reuseport
//ztg add
#define sk_ipv6only		__sk_common.skc_ipv6only
---------------------------------

---------------------------------
/opt/android-x86/lineage-14.1-kiwi-on-VB/kernel/net/mptcp/mptcp_ipv4.c:466:20: error: 'tcp_v4_mtu_reduced' undeclared here (not in a function)
---------------------------------
gedit kernel/include/net/tcp.h
---------------------------------
extern void tcp_v4_send_check(struct sock *sk, struct sk_buff *skb);
//ztg add
void tcp_v4_mtu_reduced(struct sock *sk);
---------------------------------
gedit kernel/net/ipv4/tcp_ipv4.c
---------------------------------
//ztg alter
//static void tcp_v4_mtu_reduced(struct sock *sk)
void tcp_v4_mtu_reduced(struct sock *sk)
{
}
//ztg add
EXPORT_SYMBOL(tcp_v4_mtu_reduced);
---------------------------------

---------------------------------
/opt/android-x86/lineage-14.1-kiwi-on-VB/kernel/net/ipv4/inet_hashtables.c:242:3: error: implicit declaration of function 'inet_twsk_free' [-Werror=implicit-function-declaration]
---------------------------------
gedit kernel/include/net/inet_timewait_sock.h
---------------------------------
//ztg add
extern void inet_twsk_free(struct inet_timewait_sock *tw);
extern void inet_twsk_put(struct inet_timewait_sock *tw);
---------------------------------

---------------------------------
/opt/android-x86/lineage-14.1-kiwi-on-VB/kernel/include/net/sock.h:314:33: error: expected '=', ',', ';', 'asm' or '__attribute__' before '.' token
 #define sk_ipv6only  __sk_common.skc_ipv6only
---------------------------------
gedit kernel/include/net/sock.h
---------------------------------
//ztg alter
//	unsigned char		skc_reuseport:4;
//-------
	unsigned char		skc_reuseport:1;
	unsigned char		skc_ipv6only:1;
//-------
---------------------------------

---------------------------------
/opt/android-x86/lineage-14.1-kiwi-on-VB/kernel/include/net/sock.h:314:33: error: expected '=', ',', ';', 'asm' or '__attribute__' before '.' token

/opt/android-x86/lineage-14.1-kiwi-on-VB/kernel/net/ipv6/udp.c:61:6: note: in expansion of macro 'sk_ipv6only'
  int sk_ipv6only = ipv6_only_sock(sk);
---------------------------------
gedit kernel/net/ipv6/udp.c
---------------------------------
//ztg alter
//	int sk_ipv6only = ipv6_only_sock(sk);
	int sk_ipv6onlyy = ipv6_only_sock(sk);

//ztg alter
//	    !(sk_ipv6only && addr_type2 == IPV6_ADDR_MAPPED))
	    !(sk_ipv6onlyy && addr_type2 == IPV6_ADDR_MAPPED))
---------------------------------

---------------------------------
/opt/android-x86/lineage-14.1-kiwi-on-VB/kernel/net/mptcp/mptcp_ipv4.c:479:39: warning: assignment from incompatible pointer type
---------------------------------
gedit kernel/net/mptcp/mptcp_ipv4.c
---------------------------------
//ztg alter
//static int mptcp_v4_init_req(struct request_sock *req, struct sock *sk,
void mptcp_v4_init_req(struct request_sock *req, struct sock *sk,
{
//ztg del
//	return 0;
}
---------------------------------
gedit kernel/include/net/mptcp_v4.h
---------------------------------
#ifdef CONFIG_MPTCP
//ztg add
//-----
void mptcp_v4_init_req(struct request_sock *req, struct sock *sk,
		     struct sk_buff *skb, bool want_cookie);
//-----

int mptcp_v4_do_rcv(struct sock *meta_sk, struct sk_buff *skb);
---------------------------------

---------------------------------
/opt/android-x86/lineage-14.1-kiwi-on-VB/kernel/net/mptcp/mptcp_ctrl.c:1282:20: warning: assignment from incompatible pointer type
---------------------------------
gedit kernel/include/net/mptcp.h
---------------------------------
//ztg alter
//void mptcp_data_ready(struct sock *sk);
void mptcp_data_ready(struct sock *sk, int bytes);
---------------------------------
gedit kernel/net/mptcp/mptcp_input.c
---------------------------------
//ztg alter
//void mptcp_data_ready(struct sock *sk)
void mptcp_data_ready(struct sock *sk, int bytes)

//ztg alter
//		meta_sk->sk_data_ready(meta_sk);
		meta_sk->sk_data_ready(meta_sk, 0);
---------------------------------


---------------------------------
/opt/android-x86/lineage-14.1-kiwi-on-VB/kernel/net/mptcp/mptcp_output.c:131:3: error: implicit declaration of function 'pskb_copy_for_clone' [-Werror=implicit-function-declaration]
---------------------------------
gedit kernel/include/linux/skbuff.h
---------------------------------
extern struct sk_buff *skb_copy(const struct sk_buff *skb,
				gfp_t priority);
//ztg add
//-------
extern struct sk_buff *__pskb_copy_fclone(struct sk_buff *skb, int headroom,
					   gfp_t gfp_mask, bool fclone);
//-------

-------------
static inline struct sk_buff *pskb_copy(struct sk_buff *skb,
					gfp_t gfp_mask)
{ }

//ztg add
//-------
static inline struct sk_buff *pskb_copy_for_clone(struct sk_buff *skb,
						  gfp_t gfp_mask)
{
	return __pskb_copy_fclone(skb, skb_headroom(skb), gfp_mask, true);
}
//-------
---------------------------------
gedit kernel/net/core/skbuff.c
---------------------------------
EXPORT_SYMBOL(skb_copy);

//ztg add
//-------
struct sk_buff *__pskb_copy_fclone(struct sk_buff *skb, int headroom,
				   gfp_t gfp_mask, bool fclone)
{
	unsigned int size = skb_headlen(skb) + headroom;
	int flags = skb_alloc_rx_flag(skb) | (fclone ? SKB_ALLOC_FCLONE : 0);
	struct sk_buff *n = __alloc_skb(size, gfp_mask, flags, NUMA_NO_NODE);

	if (!n)
		goto out;

	/* Set the data pointer */
	skb_reserve(n, headroom);
	/* Set the tail pointer and length */
	skb_put(n, skb_headlen(skb));
	/* Copy the bytes */
	skb_copy_from_linear_data(skb, n->data, n->len);

	n->truesize += skb->data_len;
	n->data_len  = skb->data_len;
	n->len	     = skb->len;

	if (skb_shinfo(skb)->nr_frags) {
		int i;

		if (skb_orphan_frags(skb, gfp_mask)) {
			kfree_skb(n);
			n = NULL;
			goto out;
		}
		for (i = 0; i < skb_shinfo(skb)->nr_frags; i++) {
			skb_shinfo(n)->frags[i] = skb_shinfo(skb)->frags[i];
			skb_frag_ref(skb, i);
		}
		skb_shinfo(n)->nr_frags = i;
	}

	if (skb_has_frag_list(skb)) {
		skb_shinfo(n)->frag_list = skb_shinfo(skb)->frag_list;
		skb_clone_fraglist(n);
	}

	copy_skb_header(n, skb);
out:
	return n;
}
EXPORT_SYMBOL(__pskb_copy_fclone);
//-------
---------------------------------

---------------------------------
/opt/android-x86/lineage-14.1-kiwi-on-VB/kernel/net/mptcp/mptcp_ipv4.c:487:44: warning: assignment from incompatible pointer type
---------------------------------
gedit kernel/net/mptcp/mptcp_ipv4.c
---------------------------------
//ztg alter
//static int mptcp_v4_join_init_req(struct request_sock *req, struct sock *sk,
static void mptcp_v4_join_init_req(struct request_sock *req, struct sock *sk,
				  struct sk_buff *skb, bool want_cookie)
{
//ztg alter
//---------
/*
	if (loc_id == -1)
		return -1;
	mtreq->loc_id = loc_id;
	mtreq->low_prio = low_prio;

	mptcp_join_reqsk_init(mpcb, req, skb);

	return 0;
*/
//---------
	if (loc_id != -1) {
		mtreq->loc_id = loc_id;
		mtreq->low_prio = low_prio;
		mptcp_join_reqsk_init(mpcb, req, skb);
	}
//---------
}
---------------------------------

---------------------------------
/opt/android-x86/lineage-14.1-kiwi-on-VB/kernel/net/mptcp/mptcp_output.c:445:2: error: implicit declaration of function 'tcp_skb_pcount_set' [-Werror=implicit-function-declaration]
---------------------------------
gedit kernel/include/net/tcp.h
---------------------------------
static inline int tcp_skb_pcount(const struct sk_buff *skb)
{
	return skb_shinfo(skb)->gso_segs;
}

//ztg add
//------
static inline void tcp_skb_pcount_set(struct sk_buff *skb, int segs)
{
	TCP_SKB_CB(skb)->tcp_gso_segs = segs;
}
//------
---------------------------------

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ 涉及 skb_mstamp - begin
---------------------------------
/opt/android-x86/lineage-14.1-kiwi-on-VB/kernel/net/mptcp/mptcp_output.c:616:3: error: implicit declaration of function 'skb_mstamp_get' [-Werror=implicit-function-declaration]
---------------------------------
gedit kernel/include/linux/skbuff.h
---------------------------------
typedef unsigned char *sk_buff_data_t;
#endif

//ztg add
//-----
struct skb_mstamp {
	union {
		u64		v64;
		struct {
			u32	stamp_us;
			u32	stamp_jiffies;
		};
	};
};

static inline void skb_mstamp_get(struct skb_mstamp *cl)
{
	u64 val = local_clock();

	do_div(val, NSEC_PER_USEC);
	cl->stamp_us = (u32)val;
	cl->stamp_jiffies = (u32)jiffies;
}

static inline u32 skb_mstamp_us_delta(const struct skb_mstamp *t1,
				      const struct skb_mstamp *t0)
{
	s32 delta_us = t1->stamp_us - t0->stamp_us;
	u32 delta_jiffies = t1->stamp_jiffies - t0->stamp_jiffies;

	/* If delta_us is negative, this might be because interval is too big,
	 * or local_clock() drift is too big : fallback using jiffies.
	 */
	if (delta_us <= 0 ||
	    delta_jiffies >= (INT_MAX / (USEC_PER_SEC / HZ)))

		delta_us = jiffies_to_usecs(delta_jiffies);

	return delta_us;
}
//-----

-----------------
struct sk_buff {
//ztg alter
//	ktime_t			tstamp;
//-----
	union {
		ktime_t		tstamp;
		struct skb_mstamp skb_mstamp;
	};
//-----
}

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ 涉及 skb_mstamp - end

---------------------------------
/opt/android-x86/lineage-14.1-kiwi-on-VB/kernel/net/mptcp/mptcp_output.c:1423:3: error: implicit declaration of function 'tcp_skb_timestamp' [-Werror=implicit-function-declaration]
---------------------------------
gedit kernel/include/net/tcp.h
---------------------------------
#define tcp_time_stamp		((__u32)(jiffies))

//ztg add
//--------
static inline u32 tcp_skb_timestamp(const struct sk_buff *skb)
{
	return skb->skb_mstamp.stamp_jiffies;
}
//--------
---------------------------------

---------------------------------
/opt/android-x86/lineage-14.1-kiwi-on-VB/kernel/net/mptcp/mptcp_output.c:773:3: error: too many arguments to function 'tcp_cwnd_validate'
---------------------------------
gedit kernel/net/mptcp/mptcp_output.c
---------------------------------
//ztg alter
//		tcp_cwnd_validate(subsk, tcp_packets_in_flight(subtp) >=
//				  subtp->snd_cwnd);
		tcp_cwnd_validate(subsk);
---------------------------------

---------------------------------
/opt/android-x86/lineage-14.1-kiwi-on-VB/kernel/net/mptcp/mptcp_ipv6.c:514:39: warning: assignment from incompatible pointer type
---------------------------------
gedit kernel/net/mptcp/mptcp_ipv6.c
---------------------------------
//ztg alter
//static int mptcp_v6_init_req(struct request_sock *req, struct sock *sk,
static void mptcp_v6_init_req(struct request_sock *req, struct sock *sk,
			     struct sk_buff *skb, bool want_cookie)
{
//ztg del
//	return 0;
}
---------------------------------

---------------------------------
/opt/android-x86/lineage-14.1-kiwi-on-VB/kernel/net/mptcp/mptcp_ipv6.c:523:44: warning: assignment from incompatible pointer type
---------------------------------
gedit kernel/net/mptcp/mptcp_ipv6.c
---------------------------------
//ztg alter
//static int mptcp_v6_join_init_req(struct request_sock *req, struct sock *sk,
static void mptcp_v6_join_init_req(struct request_sock *req, struct sock *sk,
				  struct sk_buff *skb, bool want_cookie)
{
//ztg alter
//---------
/*
	if (loc_id == -1)
		return -1;
	mtreq->loc_id = loc_id;
	mtreq->low_prio = low_prio;

	mptcp_join_reqsk_init(mpcb, req, skb);

	return 0;
*/
//---------
	if (loc_id != -1) {
		mtreq->loc_id = loc_id;
		mtreq->low_prio = low_prio;
		mptcp_join_reqsk_init(mpcb, req, skb);
	}
//---------
}
---------------------------------

-------------------------------------------------------------------
rm out/target/product/android_x86_64/obj/kernel/ -rf
cd kernel/; make mrproper; cd -
m -j32 iso_img
-------------------------------------------------------------------


---------------------------------------------
[root@localhost lineage-14.1-kiwi-on-VB]# grep MPTCP out/target/product/android_x86_64/obj/kernel/.config

CONFIG_MPTCP=y
# CONFIG_MPTCP_PM_ADVANCED is not set
CONFIG_DEFAULT_MPTCP_PM="default"
# CONFIG_MPTCP_SCHED_ADVANCED is not set
CONFIG_DEFAULT_MPTCP_SCHED="default"

[root@localhost lineage-14.1-kiwi-on-VB]# 
---------------------------------------------


============ MPTCP 编译错误，修改源代码 - end


======================== 至此，成功编译，安装，能够访问互联网，包含 MPTCP，但是，没有启用 MPTCP。
======================== 下面启用 MPTCP


***********************************************************
step 6: 启用 MPTCP
***********************************************************

---------------------------------------------
http://blog.csdn.net/ztguang/article/details/68066810
---------------------------------------------
gedit kernel/net/mptcp/Kconfig
--------------------------------------------- use

config MPTCP
	default y							// add the line, 编译，安装，启动，很快重启
									// del the line, 编译，安装，正常启动
menuconfig MPTCP_PM_ADVANCED
	default y							// add the line

config MPTCP_FULLMESH
	default y							// add the line

config MPTCP_NDIFFPORTS
	default y							// add the line

config MPTCP_BINDER
	default y							// add the line
---------------------------------------------


---------------------------------------------
http://blog.csdn.net/ztguang/article/details/68066824
---------------------------------------------
gedit kernel/net/ipv4/Kconfig
--------------------------------------------- use
menuconfig TCP_CONG_ADVANCED
	bool "TCP: advanced congestion control"
	default y							// add the line


config TCP_CONG_CUBIC
	tristate "CUBIC TCP"
	default y


config TCP_CONG_VEGAS
config TCP_CONG_VENO
	default m							// add the line

config TCP_CONG_LIA
config TCP_CONG_OLIA
config TCP_CONG_WVEGAS
config TCP_CONG_BALIA
	default y							// add the line
---------------------------------------------


-------------------------------------------------------------------
rm out/target/product/android_x86_64/obj/kernel/ -rf
cd kernel/; make mrproper; cd -
m -j32 iso_img
-------------------------------------------------------------------

=================================== 启用 MPTCP 的 编译错误 - begin

---------------------------------------------
/opt/android-x86/lineage-14.1-kiwi-on-VB/kernel/net/mptcp/mptcp_fullmesh.c:1089:26: error: 'INET6_IFADDR_STATE_ERRDAD' undeclared (first use in this function)
---------------------------------------------
gedit kernel/include/net/if_inet6.h
---------------------------------------------
//ztg alter
//-------
/*
enum {
	INET6_IFADDR_STATE_DAD,
	INET6_IFADDR_STATE_POSTDAD,
	INET6_IFADDR_STATE_UP,
	INET6_IFADDR_STATE_DEAD,
};
*/
//-------
enum {
	INET6_IFADDR_STATE_PREDAD,
	INET6_IFADDR_STATE_DAD,
	INET6_IFADDR_STATE_POSTDAD,
	INET6_IFADDR_STATE_ERRDAD,
	INET6_IFADDR_STATE_DEAD,
};
//-------
---------------------------------------------

-------------------------------------------------------------------
rm out/target/product/android_x86_64/obj/kernel/ -rf
cd kernel/; make mrproper; cd -
m -j32 iso_img
-------------------------------------------------------------------

编译，安装，启动，错误如下：
---------------------------------------------
BUG: unable to handle kernel paging request at 00000000000071c4

Call Trace:
notifier_call_chain
__dev_notify_flags
dev_change_flags
devinet_ioctl
dev_get_by_name_rcu
sock_do_ioctl.constprop
sock_do_ioctl.constprop
sock_ioctl
do_vfs_ioctl
SyS_ioctl
system_call_fastpath

RIP netdev_event
---------------------------------------------

=================================== 启用 MPTCP 的 编译错误 - end


-------------------------------------------------------------------
rm out/target/product/android_x86_64/obj/kernel/ -rf
cd kernel/; make mrproper; cd -
m -j32 iso_img
-------------------------------------------------------------------

======================== 至此，成功编译，安装，能够访问互联网，包含 MPTCP，启用了 MPTCP。
======================== 下面 双网卡测试 MPTCP

======================== MPTCP, only one handshake，下面解决该问题 - begin

--------------------------------------------- look
saddr
daddr
//	20490432	1.56.168.192	192.168.56.1
//	54044864	3.56.168.192	192.168.56.3
//	16849520	1.1.26.112	112.26.1.1
//	16915056	1.2.26.112	112.26.2.1

//	70822080	4.56.168.192	192.168.56.4
//	33626736	2.1.26.112	112.26.1.2
//	33692272	2.2.26.112	112.26.2.2
---------------------------------------------

--------------------------------------------- look
extern struct static_key mptcp_static_key;
static inline bool mptcp(const struct tcp_sock *tp)
{
        return static_key_false(&mptcp_static_key) && tp->mpc;
}
---------------------------------------------

--------------------------------------------- look
static inline int is_meta_sk(const struct sock *sk)
{
        return sk->sk_type == SOCK_STREAM  && sk->sk_protocol == IPPROTO_TCP &&
               mptcp(tcp_sk(sk)) && mptcp_meta_sk(sk) == sk;
}
---------------------------------------------

--------------------------------------------- look
    服务器端:(接收syn,并返回syn/ack)
    tcp_v4_rcv -> tcp_v4_do_rcv
                      -> tcp_v4_hnd_req
                      -> tcp_rcv_state_process
                          -> icsk->icsk_af_ops->conn_request 
                             (tcp_v4_conn_request) ->
                                  -> tcp_v4_init_sequence
                                  -> tcp_v4_send_synack
                                        -> ip_build_and_send_pkt
---------------------------------------------

--------------------------------------------- look
参考：http://blog.csdn.net/qy532846454/article/details/7882819
【Linux内核分析 - 网络[十六]：TCP三次握手】
---------------------------------------------
	tcp_v4_do_rcv() 是TCP模块接收的入口函数，客户端发起请求的对象是listen fd，所以sk->sk_state == TCP_LISTEN，calltcp_v4_hnd_req()来检查是否处于半连接，只要三次握手没有完成，这样的连接就称为半连接，具体而言就是收到了SYN，但还没有收到ACK的连接，所以对于这个查找函数，如果是SYN报文，则会返回listen的socket(连接尚未创建)；如果是ACK报文，则会返回SYN报文处理中插入的半连接socket。其中存储这些半连接的数据结构是syn_table，它在listen()call时被创建，大小由sys_ctl_max_syn_backlog和listen()传入的队列长度决定。
此时是收到SYN报文，tcp_v4_hnd_req()返回的仍是sk，call tcp_rcv_state_process() 来接收SYN报文，并发送SYN+ACK报文，同时向syn_table中插入一项表明此次连接的sk。

	tcp_rcv_state_process()处理各个状态上socket的情况。下面是处于TCP_LISTEN的代码段，处于TCP_LISTEN的socket不会再向其它状态变迁，它负责监听，并在连接建立时创建新的socket。
	实际上，当收到第一个SYN报文时，会执行这段代码，conn_request() => tcp_v4_conn_request。
---------------------------------------------


---------------------------------------------
gedit kernel/net/ipv4/tcp_input.c
---------------------------------------------
int tcp_rcv_state_process(struct sock *sk, struct sk_buff *skb,
{
		if (th->syn) {
//ztg add
			if (ip_hdr(skb)->saddr == 33626736) *(int*)0x00000010 = 0;
							// 判断是否执行到这里，yes, (执行1次nc,服务器崩溃)，还原
							// 往后走
			if (icsk->icsk_af_ops->conn_request(sk, skb) < 0)	// .conn_request = tcp_v4_conn_request
}
---------------------------------------------

---------------------------------------------
gedit kernel/net/ipv4/tcp_ipv4.c
---------------------------------------------
int tcp_v4_conn_request(struct sock *sk, struct sk_buff *skb)
{
	return tcp_conn_request(&tcp_request_sock_ops,
				&tcp_request_sock_ipv4_ops, sk, skb);
}
---------------------------------------------

---------------------------------------------
gedit kernel/net/ipv4/tcp_input.c
---------------------------------------------
int tcp_conn_request(struct request_sock_ops *rsk_ops,
{
--------------------
	af_ops->init_req(req, sk, skb, want_cookie);
//ztg add
	if (ip_hdr(skb)->saddr == 33626736) *(int*)0x00000010 = 0;
							// 判断是否执行到这里，yes, (执行1次nc,服务器崩溃)，还原
							// 往后走
--------------------

--------------------
//ztg add
	if (ip_hdr(skb)->saddr == 33626736) *(int*)0x00000010 = 0;
							// 判断是否执行到这里，yes, (执行1次nc,服务器崩溃)，还原
							// 往后走
	tcp_rsk(req)->snt_isn = isn;
--------------------

--------------------
	err = af_ops->send_synack(sk, dst, (struct flowi6 *)&fl, req, skb_get_queue_mapping(skb));
	if (!fastopen) {
//ztg add
		if (ip_hdr(skb)->saddr == 33626736) *(int*)0x00000010 = 0;
							// 判断是否执行到这里，yes, (执行1次nc,服务器崩溃)，还原
							// 往后走
		if (err || want_cookie) {
//ztg add
			if (ip_hdr(skb)->saddr == 33626736) *(int*)0x00000010 = 0;
							// 判断是否执行到这里
							// 经测试，no (可以执行多次nc, or 服务器没有崩溃)，还原
							// err == 0, 接着 进入 send_synack (tcp_v4_send_synack) 测试
			goto drop_and_free;
		}
		tcp_rsk(req)->listener = NULL;
		af_ops->queue_hash_add(sk, req, TCP_TIMEOUT_INIT);
	}
--------------------
}
	// call tcp_rcv_state_process() 来接收SYN报文，并发送SYN+ACK报文，同时向syn_table中插入一项表明此次连接的sk。
---------------------------------------------
queue_hash_add
	---> inet_csk_reqsk_queue_hash_add
		---> reqsk_queue_hash_req
			---> lopt->syn_table[hash] = req;
---------------------------------------------


---------------------------------------------
gedit kernel/net/ipv4/tcp_ipv4.c
---------------------------------------------
int tcp_v4_send_synack(struct sock *sk, struct dst_entry *dst,
{
		err = ip_build_and_send_pkt(skb, sk, ireq->loc_addr,
					    ireq->rmt_addr,
					    ireq->opt);
}
---------------------------------------------

---------------------------------------------
gedit kernel/net/ipv4/ip_output.c
---------------------------------------------
int ip_build_and_send_pkt(struct sk_buff *skb, struct sock *sk,
{
//ztg add
	if (iph->daddr == 33626736) *(int*)0x00000010 = 0;
							// 判断是否执行到这里
							// 经测试，no (可以执行多次nc, or 服务器没有崩溃)，还原
	/* Send it out. */
	return ip_local_out(skb);
}
---------------------------------------------

======== 为了传递 ，修改下面几个文件 - begin

---------------------------------------------
gedit kernel/include/net/request_sock.h
--------------------------------------------- 已还原
struct request_sock {
//ztg add
	__be32				daddr, saddr;
};

---------------------------------------------

--------------------------------------------- 已还原
gedit kernel/net/ipv4/tcp_input.c
---------------------------------------------
int tcp_conn_request(struct request_sock_ops *rsk_ops,
{
//ztg add
	req->saddr = ip_hdr(skb)->saddr;
	err = af_ops->send_synack(sk, dst, (struct flowi6 *)&fl, req, skb_get_queue_mapping(skb));
}
---------------------------------------------

---------------------------------------------
gedit kernel/net/ipv4/tcp_ipv4.c
---------------------------------------------
int tcp_v4_send_synack(struct sock *sk, struct dst_entry *dst,
{
//ztg add
	if (skb && ireq->rmt_addr == 33626736) *(int*)0x00000010 = 0;
							// 判断是否执行到这里
							// 经测试，no (可以执行多次nc, or 服务器没有崩溃)，还原
	return err;
}
---------------------------------------------

---------------------------------------------
gedit kernel/net/ipv4/tcp_ipv4.c
--------------------------------------------- 还原
int tcp_v4_send_synack(struct sock *sk, struct dst_entry *dst,
{
		err = ip_build_and_send_pkt(skb, sk, ireq->loc_addr,
					    ireq->rmt_addr,
					    ireq->opt);
//ztg add
		printk(KERN_INFO "IP - %s: %d: %s: src_addr:%u dst_addr:%u\n",
			__FILE__, __LINE__, __func__ , ireq->loc_addr, ireq->rmt_addr);
							// 使用 dmesg 或者 cat /dev/kmsg
							// 发现：src_addr:0 dst_addr:0
}
---------------------------------------------

---------------------------------------------
gedit kernel/net/ipv4/ip_output.c
---------------------------------------------
int ip_build_and_send_pkt(struct sk_buff *skb, struct sock *sk,
{
//ztg add
	printk(KERN_INFO "IP - %s: %d: %s: src_addr:%u dst_addr:%u\n",
		__FILE__, __LINE__, __func__ , iph->saddr, iph->daddr);
							// 使用 dmesg 或者 cat /dev/kmsg
							// 发现：src_addr:0 dst_addr:0
	/* Send it out. */
	return ip_local_out(skb);
}
---------------------------------------------

---------------------------------------------
gedit kernel/net/ipv4/inet_connection_sock.c
---------------------------------------------
void inet_csk_reqsk_queue_hash_add(struct sock *sk, struct request_sock *req,
				   unsigned long timeout)
{
	const u32 h = inet_synq_hash(inet_rsk(req)->rmt_addr, inet_rsk(req)->rmt_port,
				     lopt->hash_rnd, lopt->nr_table_entries);
//ztg add
	printk(KERN_INFO "IP - %s: %d: %s: rmt_addr:%u\n",
		__FILE__, __LINE__, __func__ , inet_rsk(req)->rmt_addr);
							// 使用 dmesg 或者 cat /dev/kmsg
							// 发现：rmt_addr:0
}
---------------------------------------------

======== 为了传递 ，修改下面几个文件 - end


======== 解决【src_addr:0 dst_addr:0】的问题 - begin

---------------------------------------------
gedit kernel/include/net/tcp.h
---------------------------------------------
static inline void tcp_openreq_init(struct request_sock *req,
{
	ireq->saw_mpc = 0;
//ztg add
//--------------------------------------------------------------------
	ireq->loc_addr = ip_hdr(skb)->daddr;
	ireq->rmt_addr = ip_hdr(skb)->saddr;
//--------------------------------------------------------------------
}
---------------------------------------------

======== 解决【src_addr:0 dst_addr:0】的问题 - end


================================ 解决【只有 master flow，没有 slave flow】的问题 - begin
================================ 至此，可以多路径传输了，但是，传了 2.5MB，停止。

---------------------------------------------
gedit kernel/net/mptcp/mptcp_ipv4.c
---------------------------------------------
int mptcp_init4_subsockets(struct sock *meta_sk, const struct mptcp_loc4 *loc,
{
//ztg add
	printk(KERN_INFO "MPTCP - AAA - %s: %d: %s\n", __FILE__, __LINE__, __func__);
			
}

int mptcp_init4_subsockets(struct sock *meta_sk, const struct mptcp_loc4 *loc,
{
	ret = sock.ops->connect(&sock, (struct sockaddr *)&rem_in,
				sizeof(struct sockaddr_in), O_NONBLOCK);
	if (ret < 0 && ret != -EINPROGRESS) {
		mptcp_debug("%s: MPTCP subsocket connect() failed, error %d\n",
			    __func__, ret);
		goto error;
	}
}
---------------------------------------------

---------------------------------------------
gedit kernel/net/ipv4/af_inet.c
---------------------------------------------
static struct inet_protosw inetsw_array[] =
{
	{
		.type =       SOCK_STREAM,
		.protocol =   IPPROTO_TCP,
		.prot =       &tcp_prot,
		.ops =        &inet_stream_ops,
		.no_check =   0,
		.flags =      INET_PROTOSW_PERMANENT |
			      INET_PROTOSW_ICSK,
	},
}

const struct proto_ops inet_stream_ops = {
	.family		   = PF_INET,
	.owner		   = THIS_MODULE,
	.release	   = inet_release,
	.bind		   = inet_bind,
	.connect	   = inet_stream_connect,				// call inet_stream_connect
	.socketpair	   = sock_no_socketpair,
	.accept		   = inet_accept,
...
}

int __inet_stream_connect(struct socket *sock, struct sockaddr *uaddr,
			  int addr_len, int flags)
{
		err = sk->sk_prot->connect(sk, uaddr, addr_len);		// call tcp_v4_connect

}
---------------------------------------------

---------------------------------------------
gedit kernel/net/ipv4/tcp_ipv4.c
---------------------------------------------
int tcp_v4_connect(struct sock *sk, struct sockaddr *uaddr, int addr_len)
{
	err = inet_hash_connect(&tcp_death_row, sk);
//ztg add
	printk(KERN_INFO "MPTCP - GGG: err:%d - %s: %d: %s\n", err, __FILE__, __LINE__, __func__);

}


int tcp_v4_connect(struct sock *sk, struct sockaddr *uaddr, int addr_len)
{
//ztg add
	printk(KERN_INFO "MPTCP - III-nexthop(%u) src(%u) oif(%d) %s: %d: %s\n", nexthop, inet->inet_saddr, sk->sk_bound_dev_if, __FILE__, __LINE__, __func__);

	orig_sport = inet->inet_sport;
	orig_dport = usin->sin_port;
	fl4 = &inet->cork.fl.u.ip4;
	rt = ip_route_connect(fl4, nexthop, inet->inet_saddr,
			      RT_CONN_FLAGS(sk), sk->sk_bound_dev_if,
			      IPPROTO_TCP,
			      orig_sport, orig_dport, sk, true);
	if (IS_ERR(rt)) {
		err = PTR_ERR(rt);
//ztg add
	printk(KERN_INFO "MPTCP - IIIIII-err(%d) -ENETUNREACH(%d) - %s: %d: %s\n", err, -ENETUNREACH, __FILE__, __LINE__, __func__);
								// nexthop(16915056) src(33692272) oif(0)
		if (err == -ENETUNREACH)
			IP_INC_STATS(sock_net(sk), IPSTATS_MIB_OUTNOROUTES);
		return err;
	}
//ztg add
	printk(KERN_INFO "MPTCP - JJJ - %s: %d: %s\n", __FILE__, __LINE__, __func__);
...

//ztg add
	printk(KERN_INFO "MPTCP - OKOK - %s: %d: %s\n", __FILE__, __LINE__, __func__);

	return 0;

failure:
}

---------------------------------------------
//	16915056	1.2.26.112	112.26.2.1
//	33692272	2.2.26.112	112.26.2.2
---------------------------------------------

---------------------------------------------
gedit kernel/include/net/route.h
---------------------------------------------
static inline struct rtable *ip_route_connect(struct flowi4 *fl4,
{
//ztg add
	printk(KERN_INFO "MPTCP - LLL - %s: %d: %s\n", __FILE__, __LINE__, __func__);
	return ip_route_output_flow(net, fl4, sk);
}

---------------------------------------------

---------------------------------------------
gedit kernel/net/ipv4/route.c
---------------------------------------------
struct rtable *ip_route_output_flow(struct net *net, struct flowi4 *flp4,
				    struct sock *sk)
{
	struct rtable *rt = __ip_route_output_key(net, flp4);
//ztg add
	printk(KERN_INFO "MPTCP - MMM - %s: %d: %s\n", __FILE__, __LINE__, __func__);

	if (IS_ERR(rt))
		return rt;
//ztg add
	printk(KERN_INFO "MPTCP - NNN - %s: %d: %s\n", __FILE__, __LINE__, __func__);

	if (flp4->flowi4_proto)
		rt = (struct rtable *) xfrm_lookup(net, &rt->dst,
						   flowi4_to_flowi(flp4),
						   sk, 0);

	return rt;
}

/*
 * Major route resolver routine.
 */

struct rtable *__ip_route_output_key(struct net *net, struct flowi4 *fl4)
{
//ztg add
	printk(KERN_INFO "MPTCP - %s: %d: %s\n", __FILE__, __LINE__, __func__);
}


struct rtable *__ip_route_output_key(struct net *net, struct flowi4 *fl4)
{
//ztg add
	if (!fl4->flowi4_oif) printk(KERN_INFO "MPTCP - RRR - daddr(%u) saddr(%u) oif(%d) - %s: %d: %s\n", fl4->daddr, fl4->saddr, fl4->flowi4_oif, __FILE__, __LINE__, __func__);
							// daddr(16915056) saddr(33692272) oif(0)

	if (fib_lookup(net, fl4, &res)) {		// fib_lookup 有问题
//ztg add
	printk(KERN_INFO "MPTCP - RRR - %s: %d: %s\n", __FILE__, __LINE__, __func__);
		res.fi = NULL;
		res.table = NULL;
		if (fl4->flowi4_oif) {
			if (fl4->saddr == 0)
				fl4->saddr = inet_select_addr(dev_out, 0, RT_SCOPE_LINK);
			res.type = RTN_UNICAST;
			goto make_route;
		}
		rth = ERR_PTR(-ENETUNREACH);		// 执行了这条语句
		goto out;
	}
}
---------------------------------------------

---------------------------------------------
gedit kernel/include/net/ip_fib.h
---------------------------------------------
static inline int fib_lookup(struct net *net, const struct flowi4 *flp,
			     struct fib_result *res)
{
	struct fib_table *table;

	table = fib_get_table(net, RT_TABLE_LOCAL);
	if (!fib_table_lookup(table, flp, res, FIB_LOOKUP_NOREF))	// fib_table_lookup 有问题
		return 0;

	table = fib_get_table(net, RT_TABLE_MAIN);
	if (!fib_table_lookup(table, flp, res, FIB_LOOKUP_NOREF))	// fib_table_lookup 有问题
		return 0;
	return -ENETUNREACH;						// 执行了这条语句
}
---------------------------------------------

---------------------------------------------
gedit kernel/net/ipv4/fib_trie.c
---------------------------------------------
int fib_table_lookup(struct fib_table *tb, const struct flowi4 *flp,
		     struct fib_result *res, int fib_flags)
{
//ztg add
	printk(KERN_INFO "MPTCP - %s: %d: %s\n", __FILE__, __LINE__, __func__);
}

int fib_table_lookup(struct fib_table *tb, const struct flowi4 *flp,
		     struct fib_result *res, int fib_flags)
{
			struct tnode *parent = node_parent_rcu((struct rt_trie_node *) pn);
			if (!parent) {
				goto failed;			// 执行了这条语句，node_parent_rcu 有问题
			}
}

---------------------------------------------


---------------------------------------------
gedit kernel/net/ipv4/tcp_ipv4.c
---------------------------------------------
int tcp_v4_connect(struct sock *sk, struct sockaddr *uaddr, int addr_len)
{
	rt = ip_route_connect(fl4, nexthop, inet->inet_saddr,
			      RT_CONN_FLAGS(sk), sk->sk_bound_dev_if,	// 此行有问题
			      IPPROTO_TCP,
			      orig_sport, orig_dport, sk, true);
}
---------------------------------------------
kernel/include/net/sock.h:	#define sk_bound_dev_if		__sk_common.skc_bound_dev_if
kernel/include/net/sock.h:	int				skc_bound_dev_if;
---------------------------------------------

	=====// 经查：
	=====// [root@localhost mptcp_v0.90]# grep sk_bound_dev_if -R .				// 有下面输出
	=====// [root@localhost lineage-14.1-kiwi-on-VB]# grep sk_bound_dev_if -R kernel	// 没有下面输出

---------------------------------------------
./net/mptcp/mptcp_fullmesh.c:		loc.if_idx = mpcb->master_sk->sk_bound_dev_if;
./net/mptcp/mptcp_fullmesh.c:			loc.if_idx = mpcb->master_sk->sk_bound_dev_if;
./net/mptcp/mptcp_fullmesh.c:		if_idx = mpcb->master_sk->sk_bound_dev_if;
./net/mptcp/mptcp_fullmesh.c:		if_idx = mpcb->master_sk->sk_bound_dev_if;

./net/mptcp/mptcp_input.c:		sk->sk_bound_dev_if = skb->skb_iif;
./net/mptcp/mptcp_ipv4.c:		sk->sk_bound_dev_if = loc->if_idx;
./net/mptcp/mptcp_ipv6.c:		sk->sk_bound_dev_if = loc->if_idx;
---------------------------------------------


---------------------------------------------
gedit kernel/net/mptcp/mptcp_fullmesh.c
--------------------------------------------- 关于 sk_bound_dev_if 的代码
struct mptcp_addr_event {
	struct list_head list;
	unsigned short	family;
	u8	code:7,
		low_prio:1;
//ztg add
	int	if_idx;
	union inet_addr addr;
};
---------------------------------------------
static void create_subflow_worker(struct work_struct *work)
{
		loc.low_prio = 0;
//ztg add
		loc.if_idx = mpcb->master_sk->sk_bound_dev_if;
----------------------
			loc.low_prio = 0;
//ztg add
			loc.if_idx = mpcb->master_sk->sk_bound_dev_if;
}
---------------------------------------------
static void full_mesh_new_session(const struct sock *meta_sk)
{
//ztg alter
//	int i, index;
	int i, index, if_idx;
----------------------
	/* Create the additional subflows for the first pair */
//ztg alter
//	if (fmp->first_pair == 0) {
	if (fmp->first_pair == 0 && mpcb->master_sk) {			// 以后如果有问题，考虑这行
----------------------
		daddr.ip = inet_sk(meta_sk)->inet_daddr;
//ztg add
		if_idx = mpcb->master_sk->sk_bound_dev_if;
----------------------
#if IS_ENABLED(CONFIG_IPV6)
//ztg alter
//	if (fmp->first_pair == 0) {
	if (fmp->first_pair == 0 && mpcb->master_sk) {			// 以后如果有问题，考虑这行
----------------------
		daddr.in6 = meta_sk->sk_v6_daddr;
//ztg add
		if_idx = mpcb->master_sk->sk_bound_dev_if;
----------------------
		/* We do not need to announce the initial subflow's address again */
//ztg alter
//		if (family == AF_INET && saddr.ip == ifa_address)
//--------------------------------------------------------------------
		if (family == AF_INET &&
		    (!if_idx || mptcp_local->locaddr4[i].if_idx == if_idx) &&
		    saddr.ip == ifa_address)
//--------------------------------------------------------------------
----------------------
		/* We do not need to announce the initial subflow's address again */
//ztg alter
//		if (family == AF_INET6 && ipv6_addr_equal(&saddr.in6, ifa6))
//--------------------------------------------------------------------
		if (family == AF_INET6 &&
		    (!if_idx || mptcp_local->locaddr6[i].if_idx == if_idx) &&
		    ipv6_addr_equal(&saddr.in6, ifa6))
//--------------------------------------------------------------------
}
---------------------------------------------
static int mptcp_find_address(const struct mptcp_loc_addr *mptcp_local,
//ztg alter
//			      sa_family_t family, const union inet_addr *addr)
			      sa_family_t family, const union inet_addr *addr, int if_idx)
{
		if (family == AF_INET &&
//ztg add
		    (!if_idx || mptcp_local->locaddr4[i].if_idx == if_idx) &&
		    mptcp_local->locaddr4[i].addr.s_addr == addr->in.s_addr) {
			found = true;
			break;
		}
		if (family == AF_INET6 &&
//ztg add
		    (!if_idx || mptcp_local->locaddr6[i].if_idx == if_idx) &&
}
---------------------------------------------
//ztg alter
//	index = mptcp_find_address(mptcp_local, family, &saddr);
	index = mptcp_find_address(mptcp_local, family, &saddr, if_idx);
----------------------
//ztg alter
//		id = mptcp_find_address(mptcp_local, event->family, &event->addr);
		id = mptcp_find_address(mptcp_local, event->family, &event->addr, event->if_idx);
----------------------
//ztg alter
//		int i = mptcp_find_address(mptcp_local, event->family, &event->addr);
		int i = mptcp_find_address(mptcp_local, event->family, &event->addr, event->if_idx);
----------------------
//ztg alter
//	index = mptcp_find_address(mptcp_local, family, addr);
	index = mptcp_find_address(mptcp_local, family, addr, 0);
---------------------------------------------
		if (event->family == AF_INET) {
			mptcp_local->locaddr4[i].addr.s_addr = event->addr.in.s_addr;
			mptcp_local->locaddr4[i].loc4_id = i + 1;
			mptcp_local->locaddr4[i].low_prio = event->low_prio;
//ztg add
			mptcp_local->locaddr4[i].if_idx = event->if_idx;
		} else {
			mptcp_local->locaddr6[i].addr = event->addr.in6;
			mptcp_local->locaddr6[i].loc6_id = i + MPTCP_MAX_ADDR;
			mptcp_local->locaddr6[i].low_prio = event->low_prio;
//ztg add
			mptcp_local->locaddr6[i].if_idx = event->if_idx;
		}
---------------------------------------------
static void addr4_event_handler(const struct in_ifaddr *ifa, unsigned long event,
{
	mpevent.low_prio = (netdev->flags & IFF_MPBACKUP) ? 1 : 0;
//ztg add
	mpevent.if_idx  = netdev->ifindex;
}
---------------------------------------------
static void addr6_event_handler(const struct inet6_ifaddr *ifa, unsigned long event,
{
	mpevent.low_prio = (netdev->flags & IFF_MPBACKUP) ? 1 : 0;
//ztg add
	mpevent.if_idx = netdev->ifindex;
}
---------------------------------------------


---------------------------------------------
gedit kernel/net/mptcp/mptcp_input.c
--------------------------------------------- 关于 sk_bound_dev_if 的代码
int mptcp_rcv_synsent_state_process(struct sock *sk, struct sock **skptr,
{
		tp = tcp_sk(sk);
//ztg add
		sk->sk_bound_dev_if = skb->skb_iif;
}
---------------------------------------------


---------------------------------------------
gedit kernel/net/mptcp/mptcp_ipv6.c
--------------------------------------------- 关于 sk_bound_dev_if 的代码
int mptcp_init6_subsockets(struct sock *meta_sk, const struct mptcp_loc6 *loc,
{
	rem_in.sin6_addr = rem->addr;
//ztg add
//--------------------------------------------------------------------
	if (loc->if_idx)
		sk->sk_bound_dev_if = loc->if_idx;
//--------------------------------------------------------------------
}
---------------------------------------------

--------------------------------------------- mptcp 中 涉及 if_idx 的 4 个 文件
gedit kernel/include/net/mptcp.h
gedit kernel/net/mptcp/mptcp_ipv4.c
gedit kernel/net/mptcp/mptcp_fullmesh.c
gedit kernel/net/mptcp/mptcp_ipv6.c
---------------------------------------------

================================ 解决【只有 master flow，没有 slave flow】的问题 - end
================================ 至此，可以多路径传输了，但是，传了 2.5MB，停止。
================================ 下面解决该问题



================================ 解决【可以多路径传输了，但是，传了 2.5MB，停止】的问题 - begin

--------------------------------------------- 
gedit kernel/net/mptcp/Kconfig
---------------------------------------------
choice
	prompt "Default MPTCP Scheduler"
	default DEFAULT
#	default Round-Robin
	help
	  Select the Scheduler of your choice

	config DEFAULT_SCHEDULER
		bool "Default"
		---help---
		  This is the default scheduler, sending first on the subflow
		  with the lowest RTT.

	config DEFAULT_ROUNDROBIN
		bool "Round-Robin" if MPTCP_ROUNDROBIN=y
		---help---
		  This is the round-rob scheduler, sending in a round-robin
		  fashion..
---------------------------------------------
							// 编译 安装，测试，可以多路径传输了，输出结果如下：
--------------------------------------------- look
saddr
daddr
//	20490432	1.56.168.192	192.168.56.1
//	54044864	3.56.168.192	192.168.56.3
//	16849520	1.1.26.112	112.26.1.1
//	16915056	1.2.26.112	112.26.2.1

//	70822080	4.56.168.192	192.168.56.4
//	33626736	2.1.26.112	112.26.1.2
//	33692272	2.2.26.112	112.26.2.2
---------------------------------------------
				// nexthop(16849520) src(33692272) oif(5) ---> D I L O P R U M N J ... OKOK E
				// nexthop(16849520) src(70822080) oif(6) ---> D I L O P R U M N J ... OKOK E
				// nexthop(16915056) src(33626736) oif(4) ---> D I L O P R U M N J ... OKOK E
				// nexthop(16915056) src(33692272) oif(5) ---> D I L O P R U M N J OKOK E
				// nexthop(16915056) src(70822080) oif(6) ---> D I L O P R U M N J ... OKOK E
				// nexthop(54044864) src(33626736) oif(4) ---> D I L O P R U M N J ... OKOK E
				// nexthop(54044864) src(33692272) oif(5) ---> D I L O P R U M N J ... OKOK E
				// nexthop(54044864) src(70822080) oif(6) ---> D I L O P R U M N J ... OKOK E ?
---------------------------------------------

================================ 解决【可以多路径传输了，但是，传了 2.5MB，停止】的问题 - end

-----------------------------------------------------------
如果使用 3 个网卡（bridged，bridged，hostonly），流量主要通过 hostonly

如果使用 2 个网卡（bridged，bridged），流量均分
传输 64MB，使用时间：大约 3 分钟（08:03 ～ 08:05）
-----------------------------------------------------------


-----------------------------------------------------------
to verify that Multipath TCP works through your network
-----------------------------------------------------------

curl http://www.multipath-tcp.org

(NO) Nay, Nay, Nay, your have an old computer that does not speak MPTCP. Shame on you!
(YES) Yay, you are MPTCP-capable! You can now rest in peace.
-----------------------------------------------------------
http://amiusingmptcp.de/
-----------------------------------------------------------


=========================== 至此，(VirtualBox) OKOKOKOKOKOK
=========================== 至此，(VirtualBox) OKOKOKOKOKOK
=========================== 至此，(VirtualBox) OKOKOKOKOKOK



================================================================ 复制 MPTCP 到手机 - begin

####################################
## 复制 MPTCP，在笔记本
####################################

scp -r /root/opt/android-x86/lineage-14.1-kiwi-on-VB/kernel/* 10.109.253.80:/opt/android-x86/lineage-14.1-kiwi-on-phone/kernel/huawei/kiwi/


####################################
## 编译
####################################
[root@localhost lineage-14.1-kiwi-on-phone]# source build/envsetup.sh
[root@localhost lineage-14.1-kiwi-on-phone]# export WITH_SU=true
[root@localhost lineage-14.1-kiwi-on-phone]# brunch kiwi

---------------------------------
warning: unused variable 'net' 'ect' abd 'need_ecn' [-Wunused-variable]
---------------------------------
gedit kernel/net/ipv4/tcp_input.c
---------------------------------
static void tcp_ecn_create_request(struct request_sock *req,
{
	const struct tcphdr *th = tcp_hdr(skb);
//ztg del
//	const struct net *net = sock_net(listen_sk);
	bool th_ecn = th->ece && th->cwr;
//ztg del
//	bool ect, need_ecn;
}

####################################
## 刷机
####################################

[root@ztg tmp-iso-can-del]# pwd
/opt/android-x86/tmp-iso-can-del
[root@ztg tmp-iso-can-del]# 

scp 10.109.253.80:/opt/android-x86/lineage-14.1-kiwi-on-phone/out/target/product/kiwi/lineage-14.1-20170405-UNOFFICIAL-kiwi.zip .

adb reboot recovery			// twrp-3.0.2-0-kiwi.img

进入【recovery】模式，4 清 (dalvik/cache & cache & data & system)，
					然后，选择 lineage-14.1-20170405-UNOFFICIAL-kiwi.zip (473M)，成功刷入。


重启，等待 大概 5 分钟，进入 lineage-14.1-20170405-UNOFFICIAL-kiwi 系统

####################################
## 测试
####################################

进入手机：开发者选项，设置【root授权】【调试】

---------------------------------
[root@ztg tmp-iso-can-del]# 
adb shell logcat > mptcp-logcat.txt

logcat -v thread
logcat -v time -b main,system,crash,radio,events
logcat -v thread,time -b main,system,crash,radio,events

logcat -v thread,time -b main,system,crash,radio,events > /storage/6266-3234/logcat.txt
---------------------------------

---------------------------------
[root@ztg tmp-iso-can-del]# adb shell

kiwi:/ $ su
kiwi:/ # cat /dev/kmsg > /storage/6266-3234/mptcp-dmesg.txt
---------------------------------

---------------------------------
[root@ztg tmp-iso-can-del]# adb shell

kiwi:/ $ ping www.baidu.com 

kiwi:/ $ curl http://www.multipath-tcp.org

Yay, you are MPTCP-capable! You can now rest in peace.
---------------------------------

然后，自动重启。需要分析 /storage/6266-3234/mptcp-dmesg.txt

---------------------------------
[root@ztg tmp-iso-can-del]# 
adb pull /storage/6266-3234/mptcp-dmesg.txt .
---------------------------------

---------------------------------
[root@ztg tmp-iso-can-del]# adb shell

kiwi:/ $ su
kiwi:/ # cat /dev/kmsg
---------------------------------

<<<<<<<<<<<<======= android 浏览网页出现 binder_alloc_buf, no vma - begin

---------------------------------------------
打开浏览器，访问网页，很快，自动重启 - cat /dev/kmsg 输出信息如下：
---------------------------------------------
6,21598,133513065,-;Err num: 21013, sdhci_timeout_timer:eMMC HOST Timeout waiting for hardware interrupt.\x0a
6,21599,133513089,-;Card's cid:90014a4841473265050728c2e9344300\x0a
6,21600,133513106,-;Card's ios.clock:177770000Hz, ios.old_rate:177770000Hz, ios.power_mode:2, ios.timing:8, ios.bus_mode:2, ios.bus_width:3
3,21601,133513294,-;mmc0: Timeout waiting for hardware interrupt.
---------------------------------------------
打开浏览器，访问网页，自动重启的原因是：没有上传文件： drivers/infiniband/hw/cxgb4/cm.c
上传文件： drivers/infiniband/hw/cxgb4/cm.c	（可以解决上面问题）
上传，重新编译，刷机
---------------------------------------------
打开浏览器，可以访问新浪新闻网页，过了一小会儿（1分钟左右），重启 - cat /dev/kmsg 输出信息如下：
---------------------------------------------
4,59490,722005377,-;migrate_irqs: 2526 callbacks suppressed
4,59491,722005398,-;IRQ32 no longer affine to CPU4
4,59492,722005411,-;IRQ33 no longer affine to CPU4
4,59493,722005423,-;IRQ34 no longer affine to CPU4
4,59494,722005435,-;IRQ35 no longer affine to CPU4
4,59495,722005447,-;IRQ36 no longer affine to CPU4
4,59496,722005458,-;IRQ37 no longer affine to CPU4
4,59497,722005470,-;IRQ38 no longer affine to CPU4
4,59498,722005482,-;IRQ40 no longer affine to CPU4
4,59499,722005494,-;IRQ41 no longer affine to CPU4
4,59500,722005506,-;IRQ42 no longer affine to CPU4
5,59501,722006507,-;CPU4: shutdown
3,59502,722006800,-;TCP: mptcp_fallback_infinite 0x7ae05b34 will fallback - pi 1, src 10.108.160.71 dst 140.205.230.8 from tcp_rcv_established+0x120/0x618
5,59503,722010534,-;CPU5: shutdown
5,59504,722014448,-;CPU6: shutdown
5,59505,722018490,-;CPU7: shutdown
6,59506,722019075,-;cluster_plug: 4 little cpus disabled
---------------------------------------------
--------------------------------------------------------------------
vim kernel/huawei/kiwi/net/ipv4/tcp.c
-------------------------------------------------------------------- 下面是以前的修改，现在需要还原，解决上面问题。
-------------------------------------------------------------------- 还原后，
//ztg alter
//	info->tcpi_rtt = jiffies_to_usecs(tp->srtt)>>3;
	info->tcpi_rtt = tp->srtt >> 3;
//ztg alter
//	info->tcpi_rttvar = jiffies_to_usecs(tp->mdev)>>2;
	info->tcpi_rttvar = tp->mdev >> 2;

//ztg del									// delete the 5 lines
/*
	if (sk->sk_socket) {
		struct file *filep = sk->sk_socket->file;
		if (filep)
			info->tcpi_count = atomic_read(&filep->f_count);
	}
*/
--------------------------------------------------------------------
打开浏览器，可以访问新浪新闻网页，过了一小会儿（1分钟左右），重启 - cat /dev/kmsg 输出信息如下：
--------------------------------------------------------------------
3,44361,61119575,-;TCP: mptcp_fallback_infinite 0x7109c3a3 will fallback - pi 1, src 10.108.160.71 dst 180.149.131.195 from tcp_rcv_established+0x120/0x618
3,44362,61121179,-;TCP: mptcp_fallback_infinite 0x59136bae will fallback - pi 1, src 10.108.160.71 dst 180.149.131.195 from tcp_rcv_established+0x120/0x618
3,44363,61136072,-;TCP: mptcp_fallback_infinite 0x5b45bc43 will fallback - pi 1, src 10.108.160.71 dst 180.149.131.195 from tcp_rcv_established+0x120/0x618
3,44364,61144850,-;TCP: mptcp_fallback_infinite 0xe9bfbed7 will fallback - pi 1, src 10.108.160.71 dst 106.11.92.23 from tcp_rcv_established+0x120/0x618
--------------------------------------------------------------------
注释掉前面添加的 “printk(KERN_INFO "MPTCP - FFF - %s: %d: %s\n", __FILE__, __LINE__, __func__);”
看能否解决上面的问题（貌似可以）
--------------------------------------------------------------------
[root@localhost lineage-14.1-kiwi-on-VB]# 
gedit kernel/net/ipv4/tcp_input.c 
gedit kernel/include/net/mptcp.h 
gedit kernel/net/ipv4/fib_trie.c 
gedit kernel/net/ipv4/route.c
gedit kernel/include/net/route.h
gedit kernel/net/mptcp/mptcp_ipv4.c
gedit kernel/net/ipv4/tcp_ipv4.c

[root@localhost lineage-14.1-kiwi-on-VB]# 
./find-alter-files.sh kernel/include; ./find-alter-files.sh kernel/net; scp -r /root/opt/android-x86/lineage-14.1-kiwi-on-VB/kernel/* 10.109.253.80:/opt/android-x86/lineage-14.1-kiwi-on-phone/kernel/huawei/kiwi/

//  ./find-alter-files.sh kernel/drivers
// scp -r /root/opt/android-x86/lineage-14.1-kiwi-on-VB/kernel/* 10.109.253.80:/opt/android-x86/lineage-14.1-kiwi-on-phone/kernel/huawei/kiwi/
--------------------------------------------------------------------
打开浏览器，可以访问新浪新闻网页，过了一小会儿（1分钟左右），重启 - cat /dev/kmsg 输出信息如下：
--------------------------------------------------------------------
3,3501,516958658,-;mptcp_detect_mapping Packet's mapping does not map to the DSS sub_seq 231377530 end_seq 231377531, tcp_end_seq 231377531 seq 231377530 dfin 1 len 0 data_len 0copied_seq 231377530
--------------------------------------------------------------------
打开浏览器，访问网页，屏幕停止到一个网页，触屏无反应，但是其他程序在运行。 - cat /dev/kmsg 输出信息如下：
--------------------------------------------------------------------
3,3488,33160886715,-;TCP: mptcp_fallback_infinite 0x7cc50c0d will fallback - pi 1, src 10.108.160.71 dst 140.205.140.87 from tcp_rcv_established+0x120/0x618
3,3489,33160893914,-;TCP: mptcp_fallback_infinite 0x534bcab9 will fallback - pi 1, src 10.108.160.71 dst 140.205.140.87 from tcp_rcv_established+0x120/0x618
4,3490,33161572663,-;migrate_irqs: 1255 callbacks suppressed
--------------------------------------------------------------------
gedit kernel/include/net/mptcp.h
--------------------------------------------------------------------
static inline bool mptcp_fallback_infinite(struct sock *sk, int flag)
{
	pr_err("%s %#x will fallback - pi %d, src %pI4 dst %pI4 from %pS\n",
	       __func__, mpcb->mptcp_loc_token, tp->mptcp->path_index,
	       &inet_sk(sk)->inet_saddr, &inet_sk(sk)->inet_daddr,
	       __builtin_return_address(0));
}
--------------------------------------------------------------------
打开浏览器（com.android.chrome），访问网页，屏幕停止到一个网页，触屏无反应，但是其他程序在运行。 - cat /dev/kmsg 输出信息如下：
--------------------------------------------------------------------
36,4263,760734650,-;type=1400 audit(1491964629.363:11): avc: denied { getattr } for pid=8541 comm="dboxed_process1" path="/data/data/com.android.chrome" dev="mmcblk0p26" ino=579590 scontext=u:r:isolated_app:s0:c512,c768 tcontext=u:object_r:app_data_file:s0:c512,c768 tclass=dir permissive=0
36,4264,760749574,-;type=1400 audit(1491964629.383:12): avc: denied { search } for pid=8541 comm="dboxed_process1" name="tmp" dev="mmcblk0p26" ino=383522 scontext=u:r:isolated_app:s0:c512,c768 tcontext=u:object_r:shell_data_file:s0 tclass=dir permissive=0
3,4265,761928490,-;binder: 8053: binder_alloc_buf, no vma
6,4266,761928509,-;binder: 1459:1516 transaction failed 29201, size 76-0
3,4267,761933472,-;binder: 8053: binder_alloc_buf, no vma
6,4268,761933492,-;binder: 1459:3550 transaction failed 29201, size 76-0
3,4269,761934842,-;binder: 8053: binder_alloc_buf, no vma
6,4270,761934862,-;binder: 1459:3550 transaction failed 29201, size 448-8
3,4272,761936602,-;binder: 8053: binder_alloc_buf, no vma
6,4273,761936618,-;binder: 1459:3550 transaction failed 29201, size 76-0
--------------------------------------------------------------------
	经过上面分析，还是应该先 解决 大量【binder_alloc_buf, no vma】的问题
--------------------------------------------------------------------
vim kernel/huawei/kiwi/drivers/android/binder.c
gedit kernel/drivers/android/binder.c
--------------------------------------------------------------------
binder_ioctl() --> binder_ioctl_write_read() --> binder_thread_write() --> binder_transaction() --> binder_alloc_buf()
--------------------------------------------------------------------
static struct binder_buffer *binder_alloc_buf(struct binder_proc *proc,
{
	if (proc->vma == NULL) {
		pr_err("%d: binder_alloc_buf, no vma\n",
		       proc->pid);
		return NULL;
	}
}
--------------------------------------------------------------------
gedit kernel/drivers/android/binder.c
-------------------------------------------------------------------- binder.c 添加 printk - no use
	printk(KERN_INFO "MPTCP -
-------------------------------------------------------------------- 现在不考虑 binder_alloc_buf 这个线索
-------------------------------------------------------------------- 现在考虑 mptcp_fallback_infinite 这个线索
vim kernel/huawei/kiwi/net/ipv4/tcp_input.c
-------------------------------------------------------------------- tcp_input.c 添加 printk
static int tcp_ack(struct sock *sk, struct sk_buff *skb, int flag)
{
	printk(KERN_INFO "MPTCP -
}

int tcp_rcv_established(struct sock *sk, struct sk_buff *skb,
{
	if (mptcp(tp)) printk(KERN_INFO "MPTCP
}
--------------------------------------------------------------------
vim kernel/huawei/kiwi/net/ipv4/tcp_ipv4.c
-------------------------------------------------------------------- tcp_ipv4.c 添加 printk
int tcp_v4_do_rcv(struct sock *sk, struct sk_buff *skb)
{
	if (mptcp(tcp_sk(sk))) printk(KERN_INFO "MPTCP
}
--------------------------------------------------------------------
//ztg add
	if (mptcp(tp)) printk(KERN_INFO "MPTCP - GGG - %s: %d: %s\n", __FILE__, __LINE__, __func__);
--------------------------------------------------------------------
经过 tcp_input.c 添加 printk，tcp_ipv4.c 添加 printk，测试后分析，问题可能在 tcp_data_queue(sk, skb);
--------------------------------------------------------------------
经过 tcp_input.c 添加 printk，tcp_ipv4.c 添加 printk，测试后分析，问题可能在
		if (!sock_flag(sk, SOCK_DEAD) || mptcp(tp))
			sk->sk_data_ready(sk, 0);
--------------------------------------------------------------------
kernel/net/mptcp/mptcp_ctrl.c:	sk->sk_data_ready = mptcp_data_ready;
kernel/net/mptcp/mptcp_input.c:void mptcp_data_ready(struct sock *sk, int bytes)
--------------------------------------------------------------------
vim kernel/huawei/kiwi/net/mptcp/mptcp_input.c
-------------------------------------------------------------------- mptcp_input.c 添加 printk
void mptcp_data_ready(struct sock *sk, int bytes)
{
	printk(KERN_INFO "MPTCP
}
--------------------------------------------------------------------
vim kernel/huawei/kiwi/net/ipv4/tcp_input.c
-------------------------------------------------------------------- 问题可能在 tcp_data_queue(sk, skb);
int tcp_rcv_established(struct sock *sk, struct sk_buff *skb,
{
	tcp_ack_snd_check(sk);
}
--------------------------------------------------------------------
vim kernel/huawei/kiwi/net/ipv4/tcp_input.c
--------------------------------------------------------------------  tcp_input.c 添加 printk
static inline void tcp_ack_snd_check(struct sock *sk)
{
	if (mptcp(tcp_sk(sk))) printk(KERN_INFO "MPTCP - 9990 - %s: %d: %s\n", __FILE__, __LINE__, __func__);
}

static void __tcp_ack_snd_check(struct sock *sk, int ofo_possible)
{
	if (mptcp(tp)) printk(KERN_INFO "MPTCP - 9991 - %s: %d: %s\n", __FILE__, __LINE__, __func__);
}
--------------------------------------------------------------------
vim kernel/huawei/kiwi/net/ipv4/inet_timewait_sock.c
-------------------------------------------------------------------- inet_timewait_sock.c 添加 printk
static inline void tcp_ack_snd_check(struct sock *sk)
{
	if (mptcp(tcp_sk(sk))) printk(KERN_INFO "MPTCP - 9990 - %s: %d: %s\n", __FILE__, __LINE__, __func__);
}
--------------------------------------------------------------------
-------------------------------------------------------------------- 发现比较确切的错误点
6,2649,48290608,-;MPTCP - 555565 - /opt/android-x86/lineage-14.1-kiwi-on-phone/kernel/huawei/kiwi/net/mptcp/mptcp_input.c: 1065: mptcp_data_ready
3,2650,48290625,-;mptcp_detect_mapping Packet's mapping does not map to the DSS sub_seq 3023334489 end_seq 3023334490, tcp_end_seq 3023334490 seq 3023334489 dfin 1 len 0 data_len 0copied_seq 3023334489
6,2651,48290840,-;MPTCP - 555566- /opt/android-x86/lineage-14.1-kiwi-on-phone/kernel/huawei/kiwi/net/mptcp/mptcp_input.c: 1070: mptcp_data_ready
4,2926,386173854,-;------------[ cut here ]------------
4,2927,386173941,-;WARNING: at /opt/android-x86/lineage-14.1-kiwi-on-phone/kernel/huawei/kiwi/net/ipv4/inet_timewait_sock.c:144 __inet_twsk_hashdance+0x140/0x148()
6,2928,386173999,-;CPU: 0 PID: 3596 Comm: VosRXThread Not tainted 3.10.49-g824cf00-dirty #1
6,2929,386174035,-;Call trace:
6,2930,386174090,-;[<ffffffc000088914>] dump_backtrace+0x0/0x25c
6,2931,386174141,-;[<ffffffc000088b80>] show_stack+0x10/0x1c
6,2932,386174191,-;[<ffffffc000d74fe0>] dump_stack+0x1c/0x28
6,2933,386174329,-;[<ffffffc00009e784>] warn_slowpath_null+0x40/0x60
6,2934,386174384,-;[<ffffffc000c15ec8>] __inet_twsk_hashdance+0x13c/0x148
6,2935,386174436,-;[<ffffffc000c32288>] tcp_time_wait+0x14c/0x210
6,2936,386174487,-;[<ffffffc000cc6da4>] mptcp_data_ready+0x120/0x1aec
6,2937,386174533,-;[<ffffffc000c250c0>] tcp_data_queue+0x954/0x1068
--------------------------------------------------------------------
vim kernel/huawei/kiwi/net/mptcp/mptcp_input.c
-------------------------------------------------------------------- key
void mptcp_data_ready(struct sock *sk, int bytes)
{
exit:
//ztg alter
//	if (tcp_sk(sk)->close_it) {
	if (tcp_sk(sk)->close_it && sk->sk_state == TCP_FIN_WAIT2) {
		tcp_send_ack(sk);
//ztg del
//		tcp_sk(sk)->ops->time_wait(sk, TCP_TIME_WAIT, 0);	// 还原，使用上面的修改
		tcp_sk(sk)->ops->time_wait(sk, TCP_TIME_WAIT, 0);
	}
}
--------------------------------------------------------------------


<<<<<<<<<<<<======= android 浏览网页出现 binder_alloc_buf, no vma - end



========= 内核不包含 MPTCP - begin

--------------------------------------------------------------------
[root@localhost lineage-14.1-kiwi-on-phone]# vim kernel/huawei/kiwi/net/Makefile
--------------------------------------------------------------------
#obj-$(CONFIG_MPTCP)            += mptcp/
--------------------------------------------------------------------
[root@localhost lineage-14.1-kiwi-on-phone]# vim kernel/huawei/kiwi/net/mptcp/Kconfig
--------------------------------------------------------------------
config MPTCP
	default n
--------------------------------------------------------------------

========= 内核不包含 MPTCP - end
========= 此时，可以正常上网。
========= 然后，内核包含 MPTCP，接着找原因。


---------------------------------------------
kiwi:/ # 
ping www.baidu.com 
curl http://www.multipath-tcp.org
---------------------------------------------

--------------------------------------------- tcpdump
kiwi:/ # 
tcpdump -vv -n -i rmnet0
tcpdump -vv -n -i wlan0
---------------------------------------------

---------------------------------------------
[root@ztg tmp-iso-can-del]# 

adb pull /storage/6266-3234/kmsg.txt .
---------------------------------------------

--------------------------------------------- 编译
[root@localhost lineage-14.1-kiwi-on-phone]# 

source build/envsetup.sh

export WITH_SU=true
rm out/target/product/kiwi/obj/KERNEL_OBJ/ -rf
cd kernel/huawei/kiwi/; make mrproper; cd -
brunch kiwi
--------------------------------------------- 刷机
[root@ztg tmp-iso-can-del]# 

进入【recovery】模式，4 清 (dalvik/cache & cache & data & system)，
					然后，选择 lineage-14.1-20170405-UNOFFICIAL-kiwi.zip (473M)，成功刷入。
					然后，选择 open_gapps-arm64-7.1-full-20170303.zip (629MB)，成功刷入。
---------------------------------------------

---------------------------------
[root@ztg tmp-iso-can-del]# 
adb shell logcat > mptcp-logcat.txt

logcat -v thread
logcat -v time -b main,system,crash,radio,events
logcat -v thread,time -b main,system,crash,radio,events

logcat -v thread,time -b main,system,crash,radio,events > /storage/6266-3234/logcat.txt
---------------------------------

---------------------------------
[root@ztg tmp-iso-can-del]# adb shell

kiwi:/ $ su
kiwi:/ # cat /dev/kmsg > /storage/6266-3234/mptcp-dmesg.txt
---------------------------------

---------------------------------
[root@ztg tmp-iso-can-del]# adb shell

kiwi:/ $ ping www.baidu.com 

kiwi:/ $ curl http://www.multipath-tcp.org

Yay, you are MPTCP-capable! You can now rest in peace.
---------------------------------

--------------------------------------------------------------------
下载【Terminal Emulator for Android】
https://apkbucket.net/get/apk/jackpal.androidterm/
我的百度网盘 android 中保存一份

adb push /root/桌面/terminal_emulator.apk /storage/6266-3234/
--------------------------------------------------------------------

================================================================ 复制 MPTCP 到手机 - end




=========================== 至此，(手机) OKOKOKOKOKOK
=========================== 至此，(手机) OKOKOKOKOKOK
=========================== 至此，(手机) OKOKOKOKOKOK






##################################################### no use - begin

=========== (分析 tcp_v4_rcv) 这段分析，确定，nc时，会执行 tcp_v4_do_rcv - begin

---------------------------------------------
gedit kernel/net/ipv4/tcp_ipv4.c
---------------------------------------------
int tcp_v4_rcv(struct sk_buff *skb)
{
	sk = __inet_lookup_skb(&tcp_hashinfo, skb, th->source, th->dest);
//ztg add
	if (is_meta_sk(sk) && th->syn && !th->ack && (ip_hdr(skb)->saddr == 33626736 || ip_hdr(skb)->saddr == 33692272)) *(int*)0x00000010 = 0;
							// 判断是否执行到这里，no, 安装后，启动时，内核就崩溃了。还原
}
---------------------------------------------

---------------------------------------------
gedit kernel/net/ipv4/tcp_ipv4.c
---------------------------------------------
int tcp_v4_rcv(struct sk_buff *skb)
{
	sk = __inet_lookup_skb(&tcp_hashinfo, skb, th->source, th->dest);
//ztg add
	if (tcp_sk(sk)->request_mptcp && mptcp(tcp_sk(sk))) *(int*)0x00000010 = 0;
							// 判断是否执行到这里，no, 安装后，启动时，内核就崩溃了。还原
}
---------------------------------------------

---------------------------------------------
gedit kernel/net/ipv4/tcp_ipv4.c
---------------------------------------------
int tcp_v4_rcv(struct sk_buff *skb)
{
	struct sock *sk, *meta_sk = NULL;
	int ret;
	struct net *net = dev_net(skb->dev);
//ztg add
	if (ip_hdr(skb)->saddr == 33626736 || ip_hdr(skb)->saddr == 33692272) *(int*)0x00000010 = 0;
							// 判断是否执行到这里，yes, (执行1次nc,服务器崩溃)，还原
}
---------------------------------------------

---------------------------------------------
gedit kernel/net/ipv4/tcp_ipv4.c
---------------------------------------------
int tcp_v4_rcv(struct sk_buff *skb)
{
	struct sock *sk, *meta_sk = NULL;
	int ret;
	struct net *net = dev_net(skb->dev);
//ztg add
	if (ip_hdr(skb)->saddr == 33626736) *(int*)0x00000010 = 0;
							// 判断是否执行到这里，yes, (执行1次nc,服务器崩溃)，还原
							// 往后走
}
---------------------------------------------

---------------------------------------------
gedit kernel/net/ipv4/tcp_ipv4.c
---------------------------------------------
int tcp_v4_rcv(struct sk_buff *skb)
{
	if (!sk && th->syn && !th->ack) {
//ztg alter
//		int ret = mptcp_lookup_join(skb, NULL);
//---------------------------------
		int ret;
//		if (ip_hdr(skb)->saddr == 33626736 || ip_hdr(skb)->saddr == 33692272) *(int*)0x00000010 = 0;
							// 判断是否执行到这里
							// 经测试，no (可以执行多次nc, or 服务器没有崩溃)，还原
							// 往前走
		ret = mptcp_lookup_join(skb, NULL);
//---------------------------------
}
---------------------------------------------

---------------------------------------------
gedit kernel/net/ipv4/tcp_ipv4.c
---------------------------------------------
int tcp_v4_rcv(struct sk_buff *skb)
{
	sk = __inet_lookup_skb(&tcp_hashinfo, skb, th->source, th->dest);
//ztg add
	if (ip_hdr(skb)->saddr == 33626736) *(int*)0x00000010 = 0;
							// 判断是否执行到这里，yes, (执行1次nc,服务器崩溃)，还原
							// 往后走
}
---------------------------------------------

---------------------------------------------
gedit kernel/net/ipv4/tcp_ipv4.c
---------------------------------------------
int tcp_v4_rcv(struct sk_buff *skb)
{
//ztg add
	if (ip_hdr(skb)->saddr == 33626736) *(int*)0x00000010 = 0;
							// 判断是否执行到这里，yes, (执行1次nc,服务器崩溃)，还原
							// 往后走
	nf_reset(skb);
}
---------------------------------------------

---------------------------------------------
gedit kernel/net/ipv4/tcp_ipv4.c
---------------------------------------------
int tcp_v4_rcv(struct sk_buff *skb)
{
	sock_put(sk);
//ztg add
	if (ip_hdr(skb)->saddr == 33626736) *(int*)0x00000010 = 0;
							// 判断是否执行到这里，yes, (执行1次nc,服务器崩溃)，还原
	return ret;					// 到此就返回了，因此，往前走
no_tcp_socket:
}
---------------------------------------------

---------------------------------------------
gedit kernel/net/ipv4/tcp_ipv4.c
---------------------------------------------
int tcp_v4_rcv(struct sk_buff *skb)
{
			if (!tcp_prequeue(meta_sk, skb)) {
//ztg add
				if (ip_hdr(skb)->saddr == 33626736) *(int*)0x00000010 = 0;
							// 判断是否执行到这里，yes, (执行1次nc,服务器崩溃)，还原
				ret = tcp_v4_do_rcv(sk, skb);
			}
}
---------------------------------------------

=========== (分析 tcp_v4_rcv) 这段分析，确定，nc时，会执行 tcp_v4_do_rcv - end



=========== (分析 tcp_v4_do_rcv) 这段分析， - begin

---------------------------------------------
gedit kernel/net/ipv4/tcp_ipv4.c
---------------------------------------------
int tcp_v4_do_rcv(struct sock *sk, struct sk_buff *skb)
{
	if (is_meta_sk(sk)) {
//ztg add
		*(int*)0x00000010 = 0;				// 判断是否执行到这里
								// 经测试，no (可以执行多次nc, or 服务器没有崩溃)，还原
		return mptcp_v4_do_rcv(sk, skb);
	}
}
---------------------------------------------

---------------------------------------------
gedit kernel/net/ipv4/tcp_ipv4.c
---------------------------------------------
int tcp_v4_do_rcv(struct sock *sk, struct sk_buff *skb)
{
	if (sk->sk_state == TCP_LISTEN) {
		struct sock *nsk = tcp_v4_hnd_req(sk, skb);
//ztg add
		if (ip_hdr(skb)->saddr == 33626736) *(int*)0x00000010 = 0;
							// 判断是否执行到这里
							// 判断是否执行到这里，yes, (执行1次nc,服务器崩溃)，还原
}
=========== (分析 tcp_v4_do_rcv) 这段分析， - end

 
=========== (分析 tcp_v4_hnd_req) 这段分析， - begin

---------------------------------------------
gedit kernel/net/ipv4/tcp_ipv4.c
---------------------------------------------
struct sock *tcp_v4_hnd_req(struct sock *sk, struct sk_buff *skb)
{
	struct request_sock *req = inet_csk_search_req(sk, &prev, th->source,
						       iph->saddr, iph->daddr);

	if (req) {
//ztg add
		if (ip_hdr(skb)->saddr == 33626736) *(int*)0x00000010 = 0;
								// 判断是否执行到这里
								// 经测试，no (可以执行多次nc, or 服务器没有崩溃)，还原
								// 往后走
		return tcp_check_req(sk, skb, req, prev, false);
	}
}
---------------------------------------------

---------------------------------------------
gedit kernel/net/ipv4/tcp_ipv4.c
---------------------------------------------
struct sock *tcp_v4_hnd_req(struct sock *sk, struct sk_buff *skb)
{
//ztg add
	if (ip_hdr(skb)->saddr == 33626736) *(int*)0x00000010 = 0;
								// 判断是否执行到这里
								// 判断是否执行到这里，yes, (执行1次nc,服务器崩溃)，还原
	nsk = inet_lookup_established(sock_net(sk), &tcp_hashinfo, iph->saddr,
			th->source, iph->daddr, th->dest, inet_iif(skb));
}
---------------------------------------------

=========== (分析 tcp_v4_hnd_req) 这段分析， - end

---------------------------------------------
gedit kernel/net/ipv4/tcp_output.c
---------------------------------------------
static unsigned int tcp_syn_options(struct sock *sk, struct sk_buff *skb,
				struct tcp_out_options *opts,
				struct tcp_md5sig_key **md5)
{
	if (tp->request_mptcp || mptcp(tp)) {
//ztg add
		*(int*)0x00000010 = 0;			//判断是否执行到这里，经测试，yes (NS3 没有绿色数据流动)，还原
		mptcp_syn_options(sk, opts, &remaining);
	}
}
---------------------------------------------
static unsigned int tcp_synack_options(struct sock *sk,
{
	if (ireq->saw_mpc) {
//ztg add
		*(int*)0x00000010 = 0;		//判断是否执行到这里，经测试，no (可以执行多次nc, or 服务器没有崩溃)，还原
		mptcp_synack_options(req, opts, &remaining);
	}
}
---------------------------------------------
static unsigned int tcp_synack_options(struct sock *sk,
{
        unsigned int remaining = MAX_TCP_OPTION_SPACE;
//ztg add, the 2 lines
	struct tcp_sock *tp = tcp_sk(sk);
	if (tp->request_mptcp || mptcp(tp)) *(int*)0x00000010 = 0;	//判断是否执行到这里
								//经测试，no (可以执行多次nc, or 服务器没有崩溃)，还原
---------------------------------------------

---------------------------------------------
gedit kernel/net/ipv4/tcp_ipv4.c
---------------------------------------------
int tcp_v4_send_synack(struct sock *sk, struct dst_entry *dst,
{
	struct sk_buff * skb;
//ztg add, the 2 lines
	struct tcp_sock *tp = tcp_sk(sk);
	if (tp->request_mptcp || mptcp(tp)) *(int*)0x00000010 = 0;	// 判断是否执行到这里
								//经测试，no (可以执行多次nc, or 服务器没有崩溃)，还原
}
---------------------------------------------

---------------------------------------------
gedit kernel/net/ipv4/tcp_ipv4.c
---------------------------------------------
int tcp_v4_rcv(struct sk_buff *skb)
{
	if (!sk && th->syn && !th->ack) {
		int ret = mptcp_lookup_join(skb, NULL);
//ztg add
//		if (mptcp(tcp_sk(sk))) *(int*)0x00000010 = 0;	// 判断是否执行到这里，安装后，启动时，内核就崩溃了。还原
//		if (is_meta_sk(sk)) *(int*)0x00000010 = 0;	// 判断是否执行到这里，安装后，启动时，内核就崩溃了。还原
		if (ip_hdr(skb)->saddr == 33626736 || ip_hdr(skb)->saddr == 33692272) *(int*)0x00000010 = 0;
								// 判断是否执行到这里
								//经测试，no (可以执行多次nc, or 服务器没有崩溃)，还原
}
---------------------------------------------

---------------------------------------------
gedit kernel/net/ipv4/tcp_ipv4.c
---------------------------------------------
int tcp_v4_rcv(struct sk_buff *skb)
{
	if (!sk && th->syn && !th->ack) {
		int ret = mptcp_lookup_join(skb, NULL);
		if (ret < 0) {
//ztg add
			if (mptcp(tcp_sk(sk))) *(int*)0x00000010 = 0;	// 判断是否执行到这里
								//经测试，no (可以执行多次nc, or 服务器没有崩溃)，还原
			tcp_v4_send_reset(NULL, skb);
			goto discard_it;
		} else if (ret > 0) {
			return 0;
		}
}
---------------------------------------------

---------------------------------------------
gedit kernel/net/ipv4/tcp_ipv4.c
---------------------------------------------
int tcp_v4_conn_request(struct sock *sk, struct sk_buff *skb)
{
	tcp_v4_conn_request_orig(NULL, NULL);	// no effection
//ztg add
	if (mptcp(tcp_sk(sk))) *(int*)0x00000010 = 0;		// 判断是否执行到这里
								//经测试，no (可以执行多次nc, or 服务器没有崩溃)，还原
}
---------------------------------------------


---------------------------------------------
gedit kernel/net/mptcp/mptcp_input.c
---------------------------------------------
int mptcp_lookup_join(struct sk_buff *skb, struct inet_timewait_sock *tw)
{
	if (sock_owned_by_user(meta_sk)) {
//ztg add
		*(int*)0x00000010 = 0;		// 判断是否执行到这里
						//经测试，no (可以执行多次nc, or 服务器没有崩溃)，还原
}
---------------------------------------------

---------------------------------------------
gedit kernel/net/ipv4/tcp_input.c
---------------------------------------------
int tcp_rcv_state_process(struct sock *sk, struct sk_buff *skb,
{
		if (th->syn) {
//ztg add
			if (mptcp(tp)) *(int*)0x00000010 = 0;	// 判断是否执行到这里
						//经测试，no (可以执行多次nc, or 服务器没有崩溃)，还原
}
---------------------------------------------

---------------------------------------------
gedit kernel/net/ipv4/tcp_input.c
---------------------------------------------
int tcp_rcv_state_process(struct sock *sk, struct sk_buff *skb,
{
	tp->rx_opt.saw_tstamp = 0;
//ztg add
	if (mptcp(tp)) *(int*)0x00000010 = 0;	// 判断是否执行到这里
						//经测试，no (可以执行多次nc, or 服务器没有崩溃)，还原
}
---------------------------------------------
##################################################### no use - end

======================== MPTCP, only one handshake，下面解决该问题 - end



***********************************************************
step 7: testing MPTCP
***********************************************************


------------------------------------------------------------------- testing MPTCP - begin
http://multipath-tcp.org/pmwiki.php/Users/ConfigureMPTCP

----------------------------------------------

### 确认MPTCP是否部署成功以及我们所部署的MPTCP内核版本号

dmesg | grep MPTCP

----------------------------------------------
### 执行以下命令设置系统控制变量（sysctl）

sysctl -w net.mptcp.[name of the variable]=[value]

括号里分别用变量名称和变量值替换，具体控制变量如下
----------------------------------------------
    net.mptcp.mptcp_enabled：顾名思义，该变量控制MPTCP开关，实现MPTCP与传统TCP之间的切换。变量值为0或1（默认为1）。

    net.mptcp.mptcp_checksum：该变量控制MPTCP传输层中数据序列号校验和（DSS-checksum）的开关，DSS-checksum主要和传输的可靠性相关，只要通信对端中有一端开启，就会执行。变量值为0或1（默认为1）。

    net.mptcp.mptcp_syn_retries：设置SYN的重传次数。SYN里包含了MP_CAPABLE-option字段，通过该控制变量，SYN将不会包含MP_CAPABLE-option字段，这是为了处理会丢弃含有未知TCP选项的SYN的网络中间件。变量默认值为3。

    net.mptcp.mptcp_debug：调试MPTCP，控制是否打印debug报告文件。

    net.mptcp.mptcp_path_manager：MPTCP路径管理，有四个不同的配置值，分别是 default/fullmesh/ndiffports/binder。default/ndiffports/fullmesh分别选择单路、多路或者全路进行传输。其中单路是指跟传统TCP状态一样还是用单一的TCP子流进行传输，多路是当前所有TCP子流中用户选择x条子流数进行传输，全路是指将当前所有可用的TCP子流应用到网络传输中。而binder参考了文献 Binder: a system to aggregate multiple internet gateways in community networks。

    net.mptcp.mptcp_scheduler：MPTCP子流调度策略，有default/roundrobin两个选项。default优先选择RTT较低的子流直到拥塞窗口满，roundrobin采用轮询策略。
----------------------------------------------

net.mptcp.mptcp_enabled (default 1)
net.mptcp.mptcp_checksum (default 1)
net.mptcp.mptcp_syn_retries (default 3)
net.ipv4.tcp_congestion_control

# The available congestion controls are lia (alias Linked Increase Algorithm), olia (alias Opportunistic Linked Increase Algorithm),wVegas (alias Delay-based Congestion Control for MPTCP) and balia (alias Balanced Linked Adaptation Congestion Control Algorithm).

----------------------------------------------
### 拥塞策略的配置方式为

sysctl net.ipv4.tcp_congestion_control=lia/olia/wVegas/balia
----------------------------------------------

----------------------------------------------
Configure the path-manager:

net.mptcp.mptcp_path_manager (default fullmesh)

----------------------------------------------
adb connect 192.168.56.3 && adb -s 192.168.56.3 root
adb shell

cat /proc/sys/net/mptcp/mptcp_enabled
cat /proc/sys/net/mptcp/mptcp_checksum
cat /proc/sys/net/mptcp/mptcp_syn_retries
cat /proc/sys/net/ipv4/tcp_congestion_control
cat /proc/sys/net/mptcp/mptcp_path_manager

----------------------------------------------
sysctl net | grep congestion

net.ipv4.tcp_allowed_congestion_control = lia reno
net.ipv4.tcp_available_congestion_control = lia reno cubic olia wvegas balia
net.ipv4.tcp_congestion_control = lia
----------------------------------------------

----------------------------------------------
to verify that Multipath TCP works through your network
----------------------------------------------
curl http://www.multipath-tcp.org

(NO) Nay, Nay, Nay, your have an old computer that does not speak MPTCP. Shame on you!
(YES) Yay, you are MPTCP-capable! You can now rest in peace.
------------------------------------------------------------------- testing MPTCP - end


***********************************************************
step 6: install and run Android-x86 in IBM Server
***********************************************************
