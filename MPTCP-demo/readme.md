# FEP: demos

# mptcp-1-path.mp4 & mptcp-2-path.mp4 : 

window W1 refers to lineage-1, windows W2 and W3 refer to the same VirtualBox instance, namely lineage-2, window W4 refers to NS-3. We first start NS-3, then run command nc in lineage-1 to make it as a file server, next run command nc in lineage-2 to download file chrome.apk (64MB) from lineage-1. After downloading the file, we run command ls in lineage-2 (W3) to find that the size of the downloaded file is the same to the size of the file in server (W1). Window W4 shows that file chrome.apk is transmitted through two paths at the same time.

# irp.mp4

Testing a simple Information Release Platform for Disaster Relief in FEP.

We run a simple Information Release Platform for Disaster Relief (IRP)  in MANET based on simplest_web_server and websocket_chat included by mongoose, and then we access IRP via a browser in lineage-irp-[2~5] respectively.
