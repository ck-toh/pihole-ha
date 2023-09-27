# Pi-hole HA Docker Container

Using keepalived to redirect Pi-hole serivces to secondary Pi-hole instances during maintainance/upgrade. Pi-hole container is running on 2 separate docker servers.

## Checking Pi-hole docker instances
Script exit code is set depending number of lines returned when checking pihole instances. We expect 2 lines returned with pihole is running
```
CONTAINER ID   NAMES     STATUS
cc2e3e90956f   pihole    Up 6 minutes (healthy)
```


### track_script in keepalived
```
#!/bin/bash
A=`docker ps --filter name=pihole --format "table {{.ID}}\t{{.Names}}\t{{.Status}}"|wc -l`
if [ $A -eq 2 ];then
    echo "pihole running";
    exit 0;
else
    echo "pihole not running";
    exit 1;
fi
```

### MASTER Node conf

```
vrrp_script chk_myscript {
  script       "/etc/keepalived/mypihole.sh"
  interval 1   # check every 1 seconds
  fall 2       # require 2 failures for KO
  rise 2       # require 2 successes for OK
}

vrrp_instance VI_1 {
        state MASTER
        interface eth0
        virtual_router_id 53
        unicast_src_ip PRIMARY_NODE_IP
        unicast_peer {
           SECONDARY_NODE_IP
        }
        priority 200
        advert_int 1
        authentication {
              auth_type PASS
              auth_pass 12345
        }
        unicast_src_ip 10.188.100.20
        unicast_peer {
           10.188.100.21
        }
        virtual_ipaddress {
              VIP_IP
        }
        track_script {
              chk_myscript
        }
}
```


### BACKUP NODE conf

```
vrrp_script chk_myscript {
  script       "/etc/keepalived/mypihole.sh"
  interval 1   # check every 1 seconds
  fall 2       # require 2 failures for KO
  rise 2       # require 2 successes for OK
}

vrrp_instance VI_1 {
        state BACKUP
        interface eth0
        virtual_router_id 53
        unicast_src_ip SECONDARY_NODE_IP
        unicast_peer {
           PRIMARY_NODE_IP
        }
        priority 199
        advert_int 1
        authentication {
              auth_type PASS
              auth_pass 12345
        }
        unicast_src_ip 10.188.100.21
        unicast_peer {
           10.188.100.20
        }
        virtual_ipaddress {
              VIP_IP
        }
        track_script {
              chk_myscript
        }
}
```
