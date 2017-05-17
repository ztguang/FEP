# gnuplot fep-test-cpu-mem.plt
# display fep-cpu-mem.png

set terminal png
set output "fep-cpu-mem.png"  

set xrange [2:9]
set yrange [0:100]

set grid

set key at 6.3,95 top Right samplen 2

set xlabel "Number of Rows (Columns) of Docker Matrices\nNumber of Lineages"
set ylabel "CPU Load Average and Memory Utilization (%)\n(32 CPU-Cores and 64 GB Memory)"

plot 'fep-test-cpu-mem-docker.dat' using 1:2 title "CPU Load Average for Docker" with lp pt 2 lc "red", \
     'fep-test-cpu-mem-docker.dat' using 1:3 title "MEM Utilization for Docker" with lp pt 3 lc "green", \
     'fep-test-cpu-mem-lineage.dat' using 1:2 title "CPU Load Average for Lineage" with lp pt 4 lc "blue", \
     'fep-test-cpu-mem-lineage.dat' using 1:3 title "MEM Utilization for Lineage" with lp pt 5

