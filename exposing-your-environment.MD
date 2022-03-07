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
