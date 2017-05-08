# gnuplot fep-test-ping.plt
# display fep-ping.png
# mv fep-ping.png /run/media/root/E6B2798BB279614B/北京邮电大学/张同光—学习总结—自写论文/PAPER/paper-7-fep/tmc
# mv fep-ping.png /root/桌面

set terminal png
set output "fep-ping.png"  

set xrange [2:9]
set yrange [0:2000]
set ytics 0,200,2000

set ytics nomirror
set y2range [0:100]
#set y2tics 5
set y2tics 0,10,100

set grid

set key top left
set xlabel "Number of Rows (Columns) of Docker Matrices"
set ylabel "The Average RTT of ping\n(milliseconds)"
set y2label "CPU Utilization of NS3 Thread-1/Thread-2 (%)"

#plot 'fep-test-ping.dat' using 1:2 title "The Average RTT of ping" with lines ls 1 lw 1 lc "red"

#plot 'fep-test-ping.dat' using 1:2 axis x1y1 title "Average RTT" with linespoints pointtype 2, \
#     'fep-test-ns3-cpu.dat' using 1:2 axis x1y2 title "CPU Utilization" with linespoints pointtype 3

plot 'fep-test-ping.dat' using 1:2 axis x1y1 title "Average RTT" with lp pt 5 lw 2 lc "blue", \
     'fep-test-ns3-cpu.dat' using 1:2 axis x1y2 title "CPU Util-Th-1" with lp pt 7 lw 1 lc "green", \
     'fep-test-ns3-cpu.dat' using 1:3 axis x1y2 title "CPU Util-Th-2" with lp pt 9 lw 1 lc "red"



