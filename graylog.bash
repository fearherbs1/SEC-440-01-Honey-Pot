# Storyline: Script to install Graylog Server on Ubuntu Servers

#!/bin/bash 

# Install Prereqs
sudo yum update && sudo yum upgrade
sudo yum install  openjdk-<version_number>-jre-headless uuid-runtime pwgen

# MongoDB - set up mongodb repository
#sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 9DA31620334BD75D9DCB49F368818C72E52529D4
#echo "deb [ arch=amd64 ] https://repo.mongodb.org/apt/ubuntu bionic/mongodb-org/4.0 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-4.0.list
sudo tee -a /etc/yum.repos.d/mongodb-org.repo > /dev/null <<EOT
[mongodb-org-4.2]
name=MongoDB Repository
baseurl=https://repo.mongodb.org/yum/redhat/$releasever/mongodb-org/4.2/x86_64/
gpgcheck=1
enabled=1
gpgkey=https://www.mongodb.org/static/pgp/server-4.2.asc
EOT

sudo yum update
sudo yum install -y mongodb-org

sudo wget -qO- 'http://keyserver.ubuntu.com/pks/lookup?op=get&search=0x9DA31620334BD75D9DCB49F368818C72E52529D4' | sudo apt-key add -
sudo systemctl daemon-reload
sudo systemctl enable mongod.service
sudo systemctl restart mongod.service
sudo systemctl --type=service --state=active | grep mongod

# Elasticsearch - Install elasticsearch 7 and configure yml file 
wget -q https://artifacts.elastic.co/GPG-KEY-elasticsearch -O myKey
sudo apt-key add myKey
echo "deb https://artifacts.elastic.co/packages/oss-7.x/apt stable main" | sudo tee -a /etc/apt/sources.list.d/elastic-7.x.list
sudo apt-get update && sudo apt-get install elasticsearch-oss
# set clustername and enable action.auto_create_index: false
sudo tee -a /etc/elasticsearch/elasticsearch.yml > /dev/null <<EOT
cluster.name: graylog
action.auto_create_index: false
EOT
sudo systemctl daemon-reload
sudo systemctl enable elasticsearch.service
sudo systemctl restart elasticsearch.service
sudo systemctl --type=service --state=active | grep elasticsearch

# Graylog - installs graylog
sudo wget https://packages.graylog2.org/repo/packages/graylog-4.2-repository_latest.deb
sudo dpkg -i graylog-4.2-repository_latest.deb
sudo apt-get update && sudo apt-get install graylog-server graylog-enterprise-plugins graylog-integrations-plugins graylog-enterprise-integrations-plugins
