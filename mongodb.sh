#!bin/bash 

ORGANIZATION=DecodeDevOps
COMPONENT=mongodb
DIRECTORY=/tmp/$COMPONENT

CATALOGUE=https://raw.githubusercontent.com/$ORGANIZATION/$COMPONENT/main/catalogue.js
USERS=https://raw.githubusercontent.com/$ORGANIZATION/$COMPONENT/main/users.js

OS=$(hostnamectl | grep 'Operating System' | tr ':', ' ' | awk '{print $3$NF}')
selinux=$(sestatus | awk '{print $NF}')

if [ $(id -u) -ne 0 ]; then
  echo -e "\e[1;33mYou need to run this as root user\e[0m"
  exit 1
fi

if [ $OS == "CentOS8" ]; then
    echo -e "\e[1;33mRunning on CentOS 8\e[0m"
    else
        echo -e "\e[1;33mOS Check not satisfied, Please user CentOS 8\e[0m"
        exit 1
fi

if [ $selinux == "disabled" ]; then
    echo -e "\e[1;33mSE Linux Disabled\e[0m"
    else
        echo -e "\e[1;33mOS Check not satisfied, Please disable SE linux\e[0m"
        exit 1
fi

hostname $COMPONENT

if [ -d $DIRECTORY ]; then
    rm -rf $DIRECTORY
    mkdir -p $DIRECTORY
    else
        mkdir -p $DIRECTORY
fi

echo -e "\e[1;33mInstalling $COMPONENT"

echo '['$COMPONENT'-org-4.2]
name=MongoDB Repository
baseurl=https://repo.'$COMPONENT'.org/yum/redhat/$releasever/'$COMPONENT'-org/4.2/x86_64/
gpgcheck=1
enabled=1
gpgkey=https://www.'$COMPONENT'.org/static/pgp/server-4.2.asc' > /etc/yum.repos.d/mongo.repo

[mongodb-org-4.2]
name=MongoDB Repository
baseurl=https://repo.mongodb.org/yum/redhat/$releasever/mongodb-org/4.2/x86_64/
gpgcheck=1
enabled=1
gpgkey=https://www.mongodb.org/static/pgp/server-4.2.asc

rpm -qa | grep mongo 
if [ $? -ne 0 ]; then
    yum install -y $COMPONENT-org
    sed -i -e 's/127.0.0.1/0.0.0.0/g' /etc/mongod.conf
    systemctl enable mongod
    systemctl restart mongod
    echo -e "\e[1;33m$COMPONENT installed and configured\e[0m"
    else
        echo -e "\e[1;32m$COMPONENT existing installation found\e[0m"
fi

echo -e "\e[1;33mDownloading and importing $COMPONENT databases\e[0m"
curl -L $USERS -o $DIRECTORY/catalogue.js
curl -L $CATALOGUE -o $DIRECTORY/users.js
mongo < $DIRECTORY/catalogue.js
mongo < $DIRECTORY/users.js

if [ $? -eq 0 ]; then
    echo -e "\e[1;33m$COMPONENT configured successfully\e[0m"
    else
        echo -e "\e[1;33mfailed to configure $COMPONENT\e[0m"
        exit 0
fi

### db.users.find().limit(10);
### db.products.find().limit(10);
### show dbs;
### use users;

# (code=exited, status=14)
# /tmp/mongodb-27017.sock