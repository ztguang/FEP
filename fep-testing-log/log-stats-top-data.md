

===========================================================================
30126 root      20   0 1638900 129940  92344 R 31.6  0.2   0:22.66 fep-manet-3x3-0
30138 root      20   0 1638900 129940  92344 S  6.6  0.2   0:04.84 fep-manet-3x3-0

30126 root      20   0 1638900 129960  92344 R 33.3  0.2   0:37.60 fep-manet-3x3-0
30138 root      20   0 1638900 129960  92344 S 11.0  0.2   0:08.09 fep-manet-3x3-0

30126 root      20   0 1638900 129980  92344 S 35.3  0.2   0:55.29 fep-manet-3x3-0
30138 root      20   0 1638900 129980  92344 S  6.7  0.2   0:11.38 fep-manet-3x3-0

30126 root      20   0 1638900 129980  92344 S 29.0  0.2   1:00.89 fep-manet-3x3-0
30138 root      20   0 1638900 129980  92344 S  5.7  0.2   0:12.49 fep-manet-3x3-0

30126 root      20   0 1638900 130036  92344 S 43.5  0.2   1:15.57 fep-manet-3x3-0
30138 root      20   0 1638900 130036  92344 S 12.3  0.2   0:15.85 fep-manet-3x3-0

30126 root      20   0 1638900 130048  92344 S 35.3  0.2   1:20.70 fep-manet-3x3-0
30138 root      20   0 1638900 130048  92344 S  9.0  0.2   0:16.92 fep-manet-3x3-0

30126 root      20   0 1638900 130064  92344 R 45.0  0.2   1:26.54 fep-manet-3x3-0
30138 root      20   0 1638900 130064  92344 R 15.0  0.2   0:18.46 fep-manet-3x3-0

30126 root      20   0 1638900 130132  92344 S 37.9  0.2   1:32.04 fep-manet-3x3-0
30138 root      20   0 1638900 130132  92344 S  8.3  0.2   0:19.82 fep-manet-3x3-0

30126 root      20   0 1638900 130140  92344 R 36.9  0.2   1:50.39 fep-manet-3x3-0
30138 root      20   0 1638900 130140  92344 S 10.6  0.2   0:24.78 fep-manet-3x3-0

30126 root      20   0 1638900 130164  92344 S 36.2  0.2   2:05.84 fep-manet-3x3-0
30138 root      20   0 1638900 130164  92344 S 10.3  0.2   0:28.50 fep-manet-3x3-0


awk 'NR%2' tmp.txt
awk '!(NR%2)' tmp.txt
(31.6+33.3+35.3+29.0+43.5+35.3+45.0+37.9+36.9+36.2)/10 = 36.4
(6.6+11.0+6.7+5.7+12.3+9.0+15.0+8.3+10.6+10.3)/10 = 9.55

===========================================================================
29189 root      20   0 2155600 130012  92016 R 60.1  0.2   0:30.82 fep-manet-4x4-0
29200 root      20   0 2155600 130012  92016 S 18.6  0.2   0:11.34 fep-manet-4x4-0

29189 root      20   0 2155600 130076  92016 R 66.3  0.2   0:59.77 fep-manet-4x4-0
29200 root      20   0 2155600 130076  92016 R 20.3  0.2   0:20.42 fep-manet-4x4-0

29189 root      20   0 2155600 130076  92016 S 62.1  0.2   1:05.27 fep-manet-4x4-0
29200 root      20   0 2155600 130076  92016 S 16.6  0.2   0:21.91 fep-manet-4x4-0

29189 root      20   0 2155600 130092  92016 R 64.7  0.2   1:19.71 fep-manet-4x4-0
29200 root      20   0 2155600 130092  92016 R 22.3  0.2   0:26.19 fep-manet-4x4-0

29189 root      20   0 2155600 130092  92016 R 57.5  0.2   1:32.32 fep-manet-4x4-0
29200 root      20   0 2155600 130092  92016 S 19.3  0.2   0:30.01 fep-manet-4x4-0

29189 root      20   0 2155600 130116  92016 R 66.3  0.2   1:45.38 fep-manet-4x4-0
29200 root      20   0 2155600 130116  92016 S 25.0  0.2   0:33.38 fep-manet-4x4-0

29189 root      20   0 2155600 130116  92016 S 63.5  0.2   2:00.74 fep-manet-4x4-0
29200 root      20   0 2155600 130116  92016 S 22.6  0.2   0:37.92 fep-manet-4x4-0

29189 root      20   0 2155600 130320  92016 S 61.0  0.2   2:31.10 fep-manet-4x4-0
29200 root      20   0 2155600 130320  92016 S 26.7  0.2   0:47.58 fep-manet-4x4-0

29189 root      20   0 2155600 130320  92016 S 62.3  0.2   2:47.64 fep-manet-4x4-0
29200 root      20   0 2155600 130320  92016 S 20.3  0.2   0:52.34 fep-manet-4x4-0

29189 root      20   0 2155600 130320  92016 S 51.3  0.2   3:00.60 fep-manet-4x4-0
29200 root      20   0 2155600 130320  92016 S 18.3  0.2   0:55.99 fep-manet-4x4-0


awk 'NR%2' tmp.txt
awk '!(NR%2)' tmp.txt
(60.1+66.3+62.1+64.7+57.5+66.3+63.5+61.0+62.3+51.3)/10 = 61.51
(18.6+20.3+16.6+22.3+19.3+25.0+22.6+26.7+20.3+18.3)/10 = 21

===========================================================================
28231 root      20   0 2820036 130948  92308 R 85.0  0.2   0:34.47 fep-manet-5x5-0
28243 root      20   0 2820036 130948  92308 S 35.3  0.2   0:16.68 fep-manet-5x5-0

28231 root      20   0 2820036 131000  92308 S 82.3  0.2   1:28.06 fep-manet-5x5-0
28243 root      20   0 2820036 131000  92308 S 30.3  0.2   0:38.96 fep-manet-5x5-0

28231 root      20   0 2820036 131000  92308 R 93.3  0.2   1:38.16 fep-manet-5x5-0
28243 root      20   0 2820036 131000  92308 S 41.0  0.2   0:43.21 fep-manet-5x5-0

28231 root      20   0 2820036 131016  92308 R 75.4  0.2   1:54.08 fep-manet-5x5-0
28243 root      20   0 2820036 131016  92308 S 28.6  0.2   0:49.11 fep-manet-5x5-0

28231 root      20   0 2820036 131016  92308 R 89.7  0.2   2:01.93 fep-manet-5x5-0
28243 root      20   0 2820036 131016  92308 S 41.7  0.2   0:52.19 fep-manet-5x5-0

28231 root      20   0 2820036 131020  92308 R 86.0  0.2   2:26.01 fep-manet-5x5-0
28243 root      20   0 2820036 131020  92308 S 35.5  0.2   1:02.42 fep-manet-5x5-0

28231 root      20   0 2820036 131052  92308 R 80.7  0.2   2:50.04 fep-manet-5x5-0
28243 root      20   0 2820036 131052  92308 S 33.7  0.2   1:13.89 fep-manet-5x5-0

28231 root      20   0 2820036 131052  92308 R 91.0  0.2   3:19.08 fep-manet-5x5-0
28243 root      20   0 2820036 131052  92308 S 37.3  0.2   1:26.37 fep-manet-5x5-0

28231 root      20   0 2820036 131052  92308 R 89.4  0.2   3:32.64 fep-manet-5x5-0
28243 root      20   0 2820036 131052  92308 S 45.8  0.2   1:31.65 fep-manet-5x5-0

28231 root      20   0 2820036 131432  92308 R 92.0  0.2   4:35.97 fep-manet-5x5-0
28243 root      20   0 2820036 131432  92308 S 33.3  0.2   1:58.23 fep-manet-5x5-0


awk 'NR%2' tmp.txt
awk '!(NR%2)' tmp.txt
(85.0+82.3+93.3+75.4+89.7+86.0+80.7+91.0+89.4+92.0)/10 = 86.48
(35.3+30.3+41.0+28.6+41.7+35.5+33.7+37.3+45.8+33.3)/10 = 36.25

===========================================================================
27293 root      20   0 3632044 131988  92356 R 91.0  0.2   0:54.41 fep-manet-6x6-0
27305 root      20   0 3632044 131988  92356 R 72.3  0.2   0:36.87 fep-manet-6x6-0

27293 root      20   0 3632044 131988  92356 R 92.0  0.2   1:10.02 fep-manet-6x6-0
27305 root      20   0 3632044 131988  92356 R 42.0  0.2   0:43.21 fep-manet-6x6-0

27293 root      20   0 3632044 131988  92356 R 90.4  0.2   1:23.63 fep-manet-6x6-0
27305 root      20   0 3632044 131988  92356 S 54.8  0.2   0:51.05 fep-manet-6x6-0

27293 root      20   0 3632044 132036  92356 R 92.4  0.2   2:10.99 fep-manet-6x6-0
27305 root      20   0 3632044 132036  92356 R 43.9  0.2   1:17.99 fep-manet-6x6-0

27293 root      20   0 3632176 132088  92356 R 94.7  0.2   2:32.85 fep-manet-6x6-0
27305 root      20   0 3632176 132088  92356 R 59.1  0.2   1:29.58 fep-manet-6x6-0

27293 root      20   0 3632176 132088  92356 R 96.0  0.2   2:46.67 fep-manet-6x6-0
27305 root      20   0 3632176 132088  92356 R 54.7  0.2   1:38.13 fep-manet-6x6-0

27293 root      20   0 3632176 132116  92356 R 90.7  0.2   3:23.11 fep-manet-6x6-0
27305 root      20   0 3632176 132116  92356 R 73.1  0.2   2:01.10 fep-manet-6x6-0

27293 root      20   0 3632176 132172  92356 R 95.3  0.2   3:51.07 fep-manet-6x6-0
27305 root      20   0 3632176 132172  92356 S 40.3  0.2   2:17.90 fep-manet-6x6-0

27293 root      20   0 3632176 132224  92356 R 97.3  0.2   4:05.43 fep-manet-6x6-0
27305 root      20   0 3632176 132224  92356 R 50.2  0.2   2:25.92 fep-manet-6x6-0

27293 root      20   0 3632176 132224  92356 R 91.3  0.2   4:13.91 fep-manet-6x6-0
27305 root      20   0 3632176 132224  92356 R 64.0  0.2   2:31.27 fep-manet-6x6-0


awk 'NR%2' tmp.txt
awk '!(NR%2)' tmp.txt
(91.0+92.0+90.4+92.4+94.7+96.0+90.7+95.3+97.3+91.3)/10 = 93.11
(72.3+42.0+54.8+43.9+59.1+54.7+73.1+40.3+50.2+64.0)/10 = 55.44

===========================================================================

24945 root      20   0 4591860 132928  91932 R 90.7  0.2   0:35.12 fep-manet-7x7-0
24957 root      20   0 4591860 132928  91932 R 80.1  0.2   0:40.00 fep-manet-7x7-0

24945 root      20   0 4591992 133036  91932 R 88.7  0.2   1:02.03 fep-manet-7x7-0
24957 root      20   0 4591992 133036  91932 R 74.7  0.2   1:02.93 fep-manet-7x7-0

24945 root      20   0 4591992 133036  91932 R 92.7  0.2   1:20.63 fep-manet-7x7-0
24957 root      20   0 4591992 133036  91932 S 70.1  0.2   1:16.14 fep-manet-7x7-0

24945 root      20   0 4591992 133096  91992 S 93.3  0.2   1:51.69 fep-manet-7x7-0
24957 root      20   0 4591992 133096  91992 R 74.3  0.2   1:42.18 fep-manet-7x7-0

24945 root      20   0 4591992 133096  91992 R 91.7  0.2   2:00.15 fep-manet-7x7-0
24957 root      20   0 4591992 133096  91992 R 63.2  0.2   1:47.52 fep-manet-7x7-0

24945 root      20   0 4591992 133816  91992 S 90.4  0.2   3:08.48 fep-manet-7x7-0
24957 root      20   0 4591992 133816  91992 R 71.8  0.2   2:42.55 fep-manet-7x7-0

24945 root      20   0 4591992 133920  91992 R 96.3  0.2   3:49.04 fep-manet-7x7-0
24957 root      20   0 4591992 133920  91992 R 65.8  0.2   3:15.09 fep-manet-7x7-0

24945 root      20   0 4591992 133920  91992 R 98.7  0.2   4:17.07 fep-manet-7x7-0
24957 root      20   0 4591992 133920  91992 R 68.8  0.2   3:34.47 fep-manet-7x7-0

24945 root      20   0 4591992 133920  91992 R 94.7  0.2   4:53.12 fep-manet-7x7-0
24957 root      20   0 4591992 133920  91992 R 70.8  0.2   4:01.82 fep-manet-7x7-0

24945 root      20   0 4591992 133928  91992 R 97.0  0.2   5:31.27 fep-manet-7x7-0
24957 root      20   0 4591992 133928  91992 R 72.7  0.2   4:32.67 fep-manet-7x7-0


awk 'NR%2' tmp.txt
awk '!(NR%2)' tmp.txt
(90.7+88.7+92.7+93.3+91.7+90.4+96.3+98.7+94.7+97.0)/10 = 93.42
(80.1+74.7+70.1+74.3+63.2+71.8+65.8+68.8+70.8+72.7)/10 = 71.23

===========================================================================

26098 root      20   0 5699152 134216  92140 R 93.7  0.2   1:08.84 fep-manet-8x8-0
26086 root      20   0 5699152 134216  92140 S 71.1  0.2   0:44.38 fep-manet-8x8-0

26098 root      20   0 5699288 134408  92140 R 91.3  0.2   2:18.76 fep-manet-8x8-0
26086 root      20   0 5699288 134408  92140 S 76.7  0.2   1:30.00 fep-manet-8x8-0

26098 root      20   0 5699288 134532  92140 R 95.1  0.2   2:48.16 fep-manet-8x8-0
26086 root      20   0 5699288 134532  92140 S 74.8  0.2   1:50.58 fep-manet-8x8-0

26098 root      20   0 5699288 134564  92140 R 89.7  0.2   3:01.54 fep-manet-8x8-0
26086 root      20   0 5699288 134564  92140 S 69.4  0.2   2:00.57 fep-manet-8x8-0

26098 root      20   0 5699288 134596  92140 R 98.0  0.2   3:31.92 fep-manet-8x8-0
26086 root      20   0 5699288 134596  92140 S 68.5  0.2   2:21.55 fep-manet-8x8-0

26098 root      20   0 5699288 134968  92200 R 95.0  0.2   3:45.26 fep-manet-8x8-0
26086 root      20   0 5699288 134968  92200 R 72.5  0.2   2:31.85 fep-manet-8x8-0

26098 root      20   0 5699288 135404  92200 R 93.2  0.2   4:17.21 fep-manet-8x8-0
26086 root      20   0 5699288 135404  92200 R 75.1  0.2   2:54.00 fep-manet-8x8-0

26098 root      20   0 5699288 135452  92200 R 93.0  0.2   5:02.15 fep-manet-8x8-0
26086 root      20   0 5699288 135452  92200 S 69.1  0.2   3:25.76 fep-manet-8x8-0

26098 root      20   0 5699288 135456  92200 R 93.8  0.2   5:28.00 fep-manet-8x8-0
26086 root      20   0 5699288 135456  92200 R 76.3  0.2   3:42.99 fep-manet-8x8-0

26098 root      20   0 5699288 135456  92200 R 96.0  0.2   5:35.66 fep-manet-8x8-0
26086 root      20   0 5699288 135456  92200 S 68.5  0.2   3:48.17 fep-manet-8x8-0
               

awk 'NR%2' tmp.txt
awk '!(NR%2)' tmp.txt
(93.7+91.3+95.1+89.7+98.0+95.0+93.2+93.0+93.8+96.0)/10 = 93.88
(71.1+76.7+74.8+69.4+68.5+72.5+75.1+69.1+76.3+68.5)/10 = 72.2
