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
