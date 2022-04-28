#!/bin/bash
sudo yum install httpd -y
echo 'Built using Packer and a shell script' >> index.html
sudo mv index.html /var/www/html/index.html
sudo systemctl enable httpd
sudo systemctl start httpd
