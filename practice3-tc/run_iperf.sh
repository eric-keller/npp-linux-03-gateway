#!/bin/bash

docker exec  clab-mod3-2ext2int-int1 iperf3 -s -p 3000 &
docker exec  clab-mod3-2ext2int-int2 iperf3 -s -p 3000 &

docker exec  clab-mod3-2ext2int-ext1 iperf3 -c 10.10.0.2 -p 3000 --logfile iperf-out.1.txt &
docker exec  clab-mod3-2ext2int-ext2 iperf3 -c 10.10.0.3 -p 3000 --logfile iperf-out.1.txt &


