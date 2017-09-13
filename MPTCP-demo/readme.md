# FEP: demos

# mptcp-1-path.mp4 & mptcp-2-path.mp4 : 

window W1 refers to lineage-1, windows W2 and W3 refer to the same VirtualBox instance, namely lineage-2, window W4 refers to NS-3. We first start NS-3, then run command nc in lineage-1 to make it as a file server, next run command nc in lineage-2 to download file chrome.apk (64MB) from lineage-1. After downloading the file, we run command ls in lineage-2 (W3) to find that the size of the downloaded file is the same to the size of the file in server (W1). Window W4 shows that file chrome.apk is transmitted through two paths at the same time.

# irp.mp4

Testing a simple Information Release Platform for Disaster Relief in FEP.

We run a simple Information Release Platform for Disaster Relief (IRP) in MANET based on simplest_web_server and websocket_chat included by mongoose, and then we access IRP (in lineage-irp-6) via a browser in lineage-irp-[1~5] respectively.

# FEP-NS3-25-100-36.mp4

We run three adhoc-grids, that is 5x5 adhoc-grid, 10x10 adhoc-grid, 6x6 adhoc-grid respectively. As can be seen from FEP-NS3-25-100-36.mp4, NS3 only use one thread to calculate the location of the nodes and relationships among nodes in adhoc-grid, the larger the number of nodes is, the slower the adhoc-grid runs. This is where improvements need to be made for NS3.
