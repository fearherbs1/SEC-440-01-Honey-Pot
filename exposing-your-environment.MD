# Exposing Your Environment

Now that our honey pot is all set up we can expose it to the internet and allow would be attackers to take their shot.

## Weak RDP
The main attack vector that we are going to open is rdp / remote deskop with a very weak password. This will allow the thousands of scanners to pickup on our vunrable enviourment. 

The key here is to set up a few accounts with rdp permissions and very bad passwords.
There is an awesome resource of commenly seen bad rdp passwords [HERE](https://krebsonsecurity.com/2013/12/hacked-via-rdp-really-dumb-passwords/).

For example I decided to set up the following ad accounts that have domain admin permission and can remote in:  
The Format is: `usrname`:`password`  
```
remote:remote
scanner:scanner
remoteuser:remoteuser
superadmin:superadmin
cathouse:cathouse
```
## Snapshots!
BEFORE EXPOSING YOUR  ENVIORMNENT TO THE INTERNET BE SURE TO TAKE SNAPSHOTS!

There is a good chance these enviorments will get destroyed by attackers and you will want a nice easy way to restore them.

## Port Forwarding

In our case we will be using ZeroTier and a VPS in order to forward our enviorments to the internet, but in essence all you need to do is forward web and rdp ports to your domain controller: 

For example if my domain controller ip is 192.168.1.101 I would use the following port forwards:

RDP: `WAN:3389 ----> 192.168.1.101:3389`  
HTTP: `WAN:80   ----> 192.168.1.101:80`  


This will allow your honeypot to be reachabe by anyone on the internet!  

