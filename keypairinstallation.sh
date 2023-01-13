# Shell script to install packages in multiple systems by ssh key pairing


#!/bin/bash

# Set IP address and domain name
hostip1="192.168.56.100"
hostip2="192.168.56.101"

# Set variables for the two Ubuntu systems

dev_server="dev.stratagile.com"
uat_server="uat.stratagile.com"

# Check if root user
if [ "$(id -u)" != "0" ]; then
    echo "This script must be run as root"
    exit 1
fi

# Add IP address and domain name to hosts file
echo "$hostip1 $dev_server" | sudo tee -a /etc/hosts
echo "$hostip2 $uat_server" | sudo tee -a /etc/hosts


# Create ssh key pair
ssh-keygen -t rsa -b 4096 -C "solvingeyes@gmail.com"

# Copy ssh key to dev_server
ssh-copy-id $dev_server

# Copy ssh key to uat_server
ssh-copy-id $uat_server

# Update apt package manager on dev_server
ssh $dev_server 'sudo apt-get update'

# Update apt package manager on uat_server
ssh $uat_server 'sudo apt-get update'

# Install nginx on dev_server
ssh $dev_server 'sudo apt-get install -y nginx'

# Install nginx on uat_server
ssh $uat_server 'sudo apt-get install -y nginx'

# Copy nginx configuration files to appropriate locations on dev_server
scp /path/to/nginx.conf $dev_server:/etc/nginx/nginx.conf
scp /path/to/default $dev_server:/etc/nginx/sites-available/default

# Copy nginx configuration files to appropriate locations on uat_server
scp /path/to/nginx.conf $uat_server:/etc/nginx/nginx.conf
scp /path/to/default $uat_server:/etc/nginx/sites-available/default

# Test nginx configuration on development server
ssh $dev_server 'nginx -t -c /etc/nginx/nginx.conf'

if [ $? -eq 0 ]
then
  ssh $dev_server 'sudo service nginx restart'
else
  echo "Error: nginx configuration tests failed on development server"
fi

# Test nginx configuration on Uat server
ssh $uat_server 'nginx -t -c /etc/nginx/nginx.conf'

if [ $? -eq 0 ]
then
  ssh $uat_server 'sudo service nginx restart'
else
  echo "Error: nginx configuration tests failed on development server"
fi

