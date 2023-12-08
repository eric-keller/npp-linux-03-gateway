# Introduction

For load balancing, the ipvs system in in Linux provides this functionaltiy.  ipvsadm is the Linux utility to manage ipvs.  

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


# Using ipvsadm

Note: at this point, there shouldn't be any filter rules (traffic can get through)

ipvs requires a kernel module to be loaded in order to provide the needed functionality.  On the host system (outside of the containers), run the following command.  Recall that containers share an operating system, so this will be available to all containers (that we run with containerlab).

```
sudo modprobe ip_vs
```

We'll run a replicated service.  So, on the gw node, you first need to add a service - the publically facing entry point for the replicated service.

```
gw ipvsadm -A -t 111.111.0.1:80 -s rr
```

Then add some backend servers.  When requests hit the service (at address 111.111.0.1), it'll be load balanced to one of these backend servers.  We'll use the masquarading mode where addresses will get translated.

```
gw ipvsadm -a -t 111.111.0.1:80 -r 10.10.0.2:8000 -m
gw ipvsadm -a -t 111.111.0.1:80 -r 10.10.0.3:8000 -m
```

To see what is configured:

```
gw ipvsadm -L -n
```

We'll use nc to create the backend servers on each of int1 and int2 nodes.

```
int1 nc -l -p 8000 -v -k
int2 nc -l -p 8000 -v -k
```

Now, we'll use nc on ext to initiate connections to the replicated service that int1 and int2 provide.  You can run this a few times - you should see the connection alternating between int1 and int2.  To see that, look at the output of the int1 nc... and int2 nc... commands.

```
ext1 bash -c 'echo "xxx" | nc -N -w 2 -v 111.111.0.1 80'
```



