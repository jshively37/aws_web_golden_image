#!/bin/bash
sudo yum install httpd -y
echo 'Favorite cat this week: Wrigley' >> index.html
sudo mv index.html /var/www/html/index.html
sudo systemctl enable httpd
sudo systemctl start httpd
