# Logging Setup

Now in order to catch the activity that attackers are doing on our honey-pot we need a way to store all of our logs in a save space with the ablitly to review them later. This is where Elastic & Elastic Security come in.

## Single Node Stack
First, you need to create a very simple single node elastic stack on your log server.   
This process is fully coverd in the guide [HERE](https://medium.com/devops-dudes/how-to-deploy-elasticsearch-5b1105e3063a) But here are the basic setup commands:

1.) Setup Repo & Install Packages:  
  
`sudo apt-get install apt-transport-https -y`  
  
`echo “deb https://artifacts.elastic.co/packages/7.x/apt stable main” | sudo tee -a /etc/apt/sources.list.d/elastic-7.x.list`  
  
`sudo apt-get update`  
  
`sudo apt-get install elasticsearch && sudo apt-get install kibana`  

2.) Configure Elasticsearch:  
Open up the config file located in: `/etc/elasticsearch/elasticsearch.yml` and change the following: in this example my log server has an ip of `192.168.1.100`  

```
cluster.name: logs-cluster        # give the cluster a descriptive name

node.name: logs-1                 # give the node a descriptive name  

network.host: 192.168.1.100       # change network binding to the log servers ip 

discovery.type: single-node       # configure as single-node cluster
```
Then start elasticsearch:  
`systemctl start elasticsearch`  

If all goes well you should be able to check if elasticsearch is running correctly with the following command:  
`curl -XGET http://192.168.1.100:9200/_cluster/health?pretty` 


3.) Configure Kibana  
Open the kibana config file located at `/etc/kibana/kibana.yml` and set the following:

```
server.port: 5601                         # port that kibana will run on

server.host: “192.168.1.100”         # IP that kibana will run on

server.name: “logs-kibana”                # kibana server name

elasticsearch.hosts: [“http://192.168.1.100:9200"] # elasticsearch to conenct to
```

Then start kibana:  
 `systemctl start kibana`

If all goes well you should be able to access the kiban web interface at:  
`http://IP:5601`


## Configure Security on Elastic
In order to use the security features with elastic, elastic minimal security and basic security need to be set up. As the documentation is ever changing Instead of providing a step by step guide Here I am going to link the elastic documentation for each step.

### First: [Minimal Security](https://www.elastic.co/guide/en/elasticsearch/reference/7.16/security-minimal-setup.html)

### Second: [Basic Security](https://www.elastic.co/guide/en/elasticsearch/reference/7.16/security-basic-setup-https.html)



## Sending logs to our stack
Now that our stack is secure we begin sending logs to it from our windows clients. We will be using both winlogbeat and sysmon to do this.

### Sysmon setup
1.) Download the latest sysmon from [HERE](https://docs.microsoft.com/en-us/sysinternals/downloads/sysmon) and extract its contents to `C:\Program Files\sysmon`  
  
2.) Download the SwiftOnSecurity Sysmon Config File from [HERE](https://github.com/SwiftOnSecurity/sysmon-config) rename it to `sysmonconfig.xml` and place it in the same folder.  

3.) Then open a admin powershell in that folder and run the following to install sysmon:  
`sysmon64.exe -accepteula -i sysmonconfig.xml`  


### Winlogbeat Setup
1.) First you must create the winlogbeat setup & writer users in elastic as seen [HERE](https://www.elastic.co/guide/en/elasticsearch/reference/7.16/security-basic-setup-https.html#configure-beats-security)  

2.) Download the latest version of winlogbeat [HERE](https://www.elastic.co/downloads/beats/winlogbeat) and extract its contents to `C:\ProgramData\winlogbeat`

3.) Create a new folder within the winlogbeat folder named `ssl` and place your `elasticsearch-ca.pem` file that you created while setting up elastic security inside of it.  

4.) Edit the following config options within `winlogbeat.yml` : **Use the setup user for this step!!**
```yaml
setup.template.settings:
  index.number_of_shards: 1
  setup.template.enabled: true


output.elasticsearch:
  # Array of hosts to connect to.
  hosts: ["192.168.1.100:9200"]

  # Protocol - either `http` (default) or `https`.
  protocol: "https"

  # Authentication credentials - either API key or username/password.
  username: "winlogbeat_setup"
  password: "Password-here"
  
  ssl:
    certificate_authorities: ["C:\\Program Files\\winlogbeat\\ssl\\elasticsearch-ca.pem"]
    verification_mode: "Certificate"

```
5.) Then open a administrator level powershell in the winlogbeat directory and run the following:  
`.\winlogbeat.exe setup -e`  
This will load the index templates & set up the winlogbeat index.  
**This only has to be done ONCE! you can set up all other instances of winlogbeat with just the writer account as seen below in the nex section**

6.) Next we need to setup the keystore.  
First create the keystore:
`.\winlogbeat.exe keystore create`  

7.) Then we need to add our writer account's password to it:  
`.\winlogbeat.exe keystore add ES_PWD`  
Then type in the password of the writer account

8.) Once the keystore is created, copy the keystore file (located in `winlogbeat\data\winlogbeat.keystore`) to the following locations:  
`C:\ProgramData\winlogbeat\`  
  
`C:\ProgramData\winlogbeat\data\`  

9.) Then edit your config to be the following:
```yaml

# ======================== Winlogbeat specific options =========================

winlogbeat.event_logs:
  - name: Application
    ignore_older: 72h

  - name: System

  - name: Security
    processors:
      - script:
          lang: javascript
          id: security
          file: ${path.home}/module/security/config/winlogbeat-security.js

  - name: Microsoft-Windows-Sysmon/Operational
    processors:
      - script:
          lang: javascript
          id: sysmon
          file: ${path.home}/module/sysmon/config/winlogbeat-sysmon.js

  - name: Windows PowerShell
    event_id: 400, 403, 600, 800
    processors:
      - script:
          lang: javascript
          id: powershell
          file: ${path.home}/module/powershell/config/winlogbeat-powershell.js

  - name: Microsoft-Windows-PowerShell/Operational
    event_id: 4103, 4104, 4105, 4106
    processors:
      - script:
          lang: javascript
          id: powershell
          file: ${path.home}/module/powershell/config/winlogbeat-powershell.js

  - name: ForwardedEvents
    tags: [forwarded]
    processors:
      - script:
          when.equals.winlog.channel: Security
          lang: javascript
          id: security
          file: ${path.home}/module/security/config/winlogbeat-security.js
      - script:
          when.equals.winlog.channel: Microsoft-Windows-Sysmon/Operational
          lang: javascript
          id: sysmon
          file: ${path.home}/module/sysmon/config/winlogbeat-sysmon.js
      - script:
          when.equals.winlog.channel: Windows PowerShell
          lang: javascript
          id: powershell
          file: ${path.home}/module/powershell/config/winlogbeat-powershell.js
      - script:
          when.equals.winlog.channel: Microsoft-Windows-PowerShell/Operational
          lang: javascript
          id: powershell
          file: ${path.home}/module/powershell/config/winlogbeat-powershell.js
  - name: Microsoft-Windows-Sysmon/Operational
    processors:
      - script:
          lang: javascript
          id: sysmon
          file: ${path.home}/module/sysmon/config/winlogbeat-sysmon.js

setup.template.settings:
  index.number_of_shards: 1
  setup.template.enabled: false


# ================================== Outputs ===================================

# ---------------------------- Elasticsearch Output ----------------------------
output.elasticsearch:
  hosts: ["192.168.1.100:9200"] # log server IP
  protocol: "https"
  username: "winlogbeat" # username of your winlogbeat writer user
  password: "${ES_PWD}"
  
  ssl:
    certificate_authorities: ["C:\\Program Files\\winlogbeat\\ssl\\elasticsearch-ca.pem"]
    verification_mode: "Certificate"
# ================================= Processors =================================
processors:
  - add_host_metadata:
      when.not.contains.tags: forwarded
  - add_cloud_metadata: ~
```


10.) Now using an admin powershell run the `install-service-winlogbeat.ps1` powershell script to install the winlogbeat service.


11.) Start the service `net start winlogbeat`    
Note: if the service does not start you can run winlogbeat manualy from the commandline with `.\winlogbeat.exe -e` to see error output.  


12.) If all is well you should be able to see logs flowing into the winlogbeat index on kibana!:
  
![](https://i.imgur.com/ZPickro.png)  




## Setup Elastic Security

### Kibana Encryption key

Before we can create detections we first need a kibana encryption key. Set the following in your `kibana.yml` and then restart kibana:  

```yaml
xpack.security.encryptionKey: "something_at_least_32_characters"
```


(todo)  
