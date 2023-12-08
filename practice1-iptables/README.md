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


It can be helpful to refer to this picture, to understand what table / chain to use:
![Netfilter Packet Flow](https://en.wikipedia.org/wiki/Netfilter#/media/File:Netfilter-packet-flow.svg)


# Part 1 - Simple filtering on a source IP


See what rules there are (-v is verbose, -n is numeric)
```
gw iptables -L -v -n --line-numbers
```

filter out traffic from ext1 (100.100.100.1)

```
gw iptables -A FORWARD -s 100.100.100.1 -j DROP
```

we'll use nc to open a server at port 1000 (container int1).  nc (or netcat) allows for arbitrary TCP and UDP connections and listens

```
int1 nc -l -p 1000 -v -k
```

we'll use nc to connect to that server from ext1 this is echoing xxx and piping that to nc which will send that to the server.
- -N shuts down after EOF from input (meaning it won't continue waiting for more input)
- -w sets a wait time to 2 seconds
- -v 

```
ext1 bash -c 'echo "xxx" | nc -N -w 2 -v 10.10.0.2 1000'
ext2 bash -c 'echo "xxx" | nc -N -w 2 -v 10.10.0.2 1000'
```

you should see ext1 failed, ext2 succeeded

to delete rules, you use a command like this (delete the rule at line number 1 from the FORWARD chain)

```
gw iptables -D FORWARD 1
```


# Part 2 - block all traffic except to port 1000

Now, let's block all traffic except to port 1000 first set the default policy to DROP, then add a rule to accept tcp traffic dest to port 1000

```
gw iptables -P FORWARD DROP
gw iptables -A FORWARD -p tcp --dport 1000 -j ACCEPT
```


we can use watch to continually update the output of iptables -L
```
gw watch iptables -L -v -x --line-numbers
```

Note: this didn't work.  We're blocking the return traffic (from int to ext)

so, let's allow everything from eth2
```
gw iptables -A FORWARD -i eth2 -j ACCEPT
```

or allow 10.10.0.0/16) - let's replace it (-R FORWARD 2 says to replace rule 2 in the FORWARD chain)
```
gw iptables -R FORWARD 2 -s 10.10.0.0/16 -j ACCEPT
```

Delete those two rules

```
gw  iptables -D FORWARD 1
gw  iptables -D FORWARD 1
```

# Part 3 - block everything except connections initiated internally

Now, let's block everything from external, unless it was a connection initiated internally.  We'll use connection tracking. We'll keep the default policy as DROP

```
gw iptables -A FORWARD -s 10.10.0.0/16 -j ACCEPT
gw iptables -A FORWARD -d 10.10.0.0/16 -m state --state RELATED,ESTABLISHED -j ACCEPT
```

Again, use nc to create connections.  This time, we'll run the server on ext1, and have the client be int1.  So, int1 is initiating a connection internally to an external server, so the gw node will do connection tracking and allow return traffic from ext1 to int1 for that specific connection.

```
ext1 nc -l -p 2000 -v -k
int1 bash -c 'echo "xxx" | nc -N -w 2 -v 100.100.100.1 2000'
```



# Part 4 - Network Address Translation (NAT)

Now let's do some NATing.  

Need to set the default policy back to accept
```
gw iptables  -P FORWARD ACCEPT
```


for ext to int direction, change the destination from 111.111.0.1 to 10.10.0.2 - do that before routing

```
gw iptables -t nat -A PREROUTING -d 111.111.0.1 -p tcp --dport 1000 -j DNAT --to-destination 10.10.0.2
```

for int to ext, the destination will be ext1's ip address so, we want that to get forwarded, but we'll want to change the source to 111.111.0.1 after routing decision has been made

```
gw iptables -t nat -A POSTROUTING -s 10.10.0.2 -p tcp --sport 1000 -j SNAT --to-source 111.111.0.1
```

We'll have the server running internally, again using nc.  So, int1 is running nc
```
int1 nc -l -p 1000 -v -k
```

ext1 will try to connect to 111.111.0.1 (which gets DNAT to 10.10.0.2)
```
ext1 bash -c 'echo "xxx" | nc -N -w 2 -v 111.111.0.1 1000'
```

delete these entries
```
gw iptables -t nat -D PREROUTING 1
gw iptables -t nat -D POSTROUTING 2
```





