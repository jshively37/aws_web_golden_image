#!/bin/bash
sudo yum install httpd -y
echo 'Built using HCP Packer and a shell script (production channel v4)' >> index.html
sudo mv index.html /var/www/html/index.html
sudo systemctl enable httpd
sudo systemctl start httpd
