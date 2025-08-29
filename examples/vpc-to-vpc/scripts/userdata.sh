#!/bin/bash
set -e
apt update -y
apt install nginx -y

rm -f /var/www/html/*.html

ip=$(hostname -I | awk '{print $1}')
host=$(hostname)

echo "<h1>Hello from $host - $ip</h1>" | tee /var/www/html/index.html
chmod go+r /var/www/html/index.html

systemctl enable nginx
systemctl start nginx
