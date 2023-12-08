# Introduction

For packet filtering and network address translation, the iptables utility provides

# Setup

See the [Common Setup](../common-setup/README.md) in the common-setup directory of this repo.


NOTE: there are alias set for each of the docker containers, as shown below:

```
alias ext1="docker exec -it  clab-mod3-2ext2int-ext1"
alias ext2="docker exec -it  clab-mod3-2ext2int-ext2"
alias int1="docker exec -it  clab-mod3-2ext2int-int1"
alias int2="docker exec -it  clab-mod3-2ext2int-int2"
alias gw="docker exec -it  clab-mod3-2ext2int-gw"
```

So, when a command is shown like gw iptables, that is executing the command iptables inside of the gw container


# Baseline throughput

To get a baseline throughput with no rate limiting, we'll use a tool, iperf3.  With iperf3, you run it in server mode on one node, and in client mode on another, and it measures throughput and latency of the path between the two nodes.  For our puproses, we'll use this in server mode on the internal nodes, and client mode (connecting to the servers) on the external nodes.  We'll run iperf from ext1 to int1, then from ext2 to int2.  This is provided as a convience script - run_iperf.sh.

```
int1 iperf3 -s -p 3000 &
int2 iperf3 -s -p 3000 &

ext1 iperf3 -c 10.10.0.2 -p 3000 --logfile iperf-out.1.txt &
ext2 iperf3 -c 10.10.0.3 -p 3000 --logfile iperf-out.1.txt &
```

To run, I had 4 open terminals.  Ran iperf3 -s in the first two.  Then had a horizontally split terminals - and ran the ext1->int1 client in one, and quickly ran the ext2->int2 client in the other

You can also ping from the ext1 to int1 and ext2 to int2

```
ext1 ping 10.10.0.2
ext2 ping 10.10.0.3
```

# Rate limit traffic

Now, lets limit the rate of traffic to the back end server.  This is done by adding a qdisc to the eth2 interface. 

```
gw tc qdisc add dev eth2 root handle 1: tbf rate 1mbit burst 32kbit latency 400ms
```

Now, try re-running iperf and ping as described above, and see the performance difference.

