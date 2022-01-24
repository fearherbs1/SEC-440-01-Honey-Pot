# Initial Setup
Welcome! This section will include some tips for setting up your honeypot enviorment.

## Required Servers
For this honeypot we will have 4 diffrent servers/clients:

* 1 Windows Domain Controller (Windows Server 2019)
* 1 Windows Domain Clinet (Windows 10)
* 1 pfSense Router (FreeBSD)
* 1 Ubuntu Log Server (Ubuntu Server 20 LTS)

For This guide we will be using VMs hosted on vCenter, but any other virtualization platform will work fine. 

## Setup of each device
Below is a summery/checklist of what to set up on each device

### pfSense Router:
This is good to set up first to allow your clients to have network access:
1.) Assign network interfaces.  
2.) Follow throught the pfsense wizzard to set up general settings.  
3.) Set a strong password here, we do not want any attackers to easily be able to access this box!  


### Windows Domain Controller:
1.) Install Windows server.  
2.) Give it a weak local Admin Password.  
3.) Install Active Directory and set up a domain, be sure to make the name somewhat believable.   
4.) Set up forward and reverse DNS lookup Zones.  
5.) Set up an admin and user account with weak passwords.  
6.) Install windows ISS server and make sure it is running.  
7.) Set a wallpaper that fits your domains name.    
8.) Set a Static IP.  


### Windows Domain Client
1.) Install Windows 10.  
2.) Set a weak local Admin password.  
3.) change computer name to fit the theme.  
4.) Join the domain you created on the Domain Controller.  
5.) Log into the Domain Client with the user you created in Active Directory.  


### Log Server:
1.) Install Ubuntu Server  
2.) Set up a secure user, we do not want any attackers to easily be able to access this box!  
3.) Set up a static IP.  
4.) Fully update the Server.  
