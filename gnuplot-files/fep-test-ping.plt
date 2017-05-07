# gnuplot fep-test-ping.plt
# display fep-ping.png
# mv fep-ping.png /run/media/root/E6B2798BB279614B/北京邮电大学/张同光—学习总结—自写论文/PAPER/paper-7-fep/tmc

set terminal png
set output "fep-ping.png"  

set xrange [2:8]
set yrange [0:1800]

set grid

set key top left
set xlabel "Number of Rows (Columns) of Docker Matrices"
set ylabel "The Average RTT of ping\n(milliseconds)"

#plot 'fep-test-ping.dat' using 1:2 title "The Average RTT of ping" with lines ls 1 lw 1 lc "red"

plot 'fep-test-ping.dat' using 1:2 title "The Average RTT of ping" with linespoints pointtype 2







