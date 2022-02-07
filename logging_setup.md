# Logging Setup

Now in order to catch the activity that attackers are doing on our honey-pot we need a way to store all of our logs in a save space with the ablitly to review them later. This is where Elastic & Elastic Security come in.

## Single Node Stack
First, you need to create a very simple single node elastic stack on your log server.   
This process is fully coverd in the guide [HERE](https://medium.com/devops-dudes/how-to-deploy-elasticsearch-5b1105e3063a) But here are the basic setup commands:

1.) Setup Repo & Install Packages:  
`https://medium.com/devops-dudes/how-to-deploy-elasticsearch-5b1105e3063a`  
  
`sudo apt-get install apt-transport-https -y`  
  
`echo “deb https://artifacts.elastic.co/packages/7.x/apt stable main” | sudo tee -a /etc/apt/sources.list.d/elastic-7.x.list`  
  
`sudo apt-get update`  
  
`sudo apt-get install elasticsearch && sudo apt-get install kibana`  

2.) Configure Elasticsearch:  
Open up the config file located in: `/etc/elasticsearch/elasticsearch.yml`
