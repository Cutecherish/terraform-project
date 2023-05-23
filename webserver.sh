#!/bin/bash

yum update -y
yum install httpd -y
sudo systemctl start httpd
sudo systemctl enable httpd
echo "this is my first terraform webserver" > /var/www/html/index.html