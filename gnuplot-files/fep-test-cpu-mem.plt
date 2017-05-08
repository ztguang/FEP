# gnuplot fep-test-cpu-mem.plt
# display fep-cpu-mem.png
# mv fep-cpu-mem.png /run/media/root/E6B2798BB279614B/北京邮电大学/张同光—学习总结—自写论文/PAPER/paper-7-fep/tmc
# mv fep-cpu-mem.png /root/桌面

set terminal png
set output "fep-cpu-mem.png"  

set xrange [2:9]
set yrange [0:100]

set grid

set key top left
set xlabel "Number of Rows (Columns) of Docker Matrices\nNumber of Lineages"
set ylabel "CPU and Memory Utilization\n(32 CPU-Cores and 64 GB Memory)"

#plot 'fep-test-cpu-mem-docker.dat' using 1:2 title "CPU Utilization for Docker" with lines ls 1 lw 1 lc "red", \
#     'fep-test-cpu-mem-docker.dat' using 1:3 title "MEM Utilization for Docker" with lines ls 1 lw 1 lc "yellow", \
#     'fep-test-cpu-mem-lineage.dat' using 1:2 title "CPU Utilization for Lineage" with lines ls 1 lw 1 lc "green", \
#     'fep-test-cpu-mem-lineage.dat' using 1:3 title "MEM Utilization for Lineage" with lines ls 1 lw 1 lc "blue"

#plot 'fep-test-cpu-mem-docker.dat' using 1:2 title "CPU Utilization for Docker" with linespoints pointtype 2

plot 'fep-test-cpu-mem-docker.dat' using 1:2 title "CPU Utilization for Docker" with lp pt 2 lc "red", \
     'fep-test-cpu-mem-docker.dat' using 1:3 title "MEM Utilization for Docker" with lp pt 3 lc "green", \
     'fep-test-cpu-mem-lineage.dat' using 1:2 title "CPU Utilization for Lineage" with lp pt 4 lc "blue", \
     'fep-test-cpu-mem-lineage.dat' using 1:3 title "MEM Utilization for Lineage" with lp pt 5
