#!/bin/bash
sudo yum update -y
sudo amazon-linux-extras install -y nginx1
sudo systemctl start nginx
sudo systemctl enable nginx
echo '<html><head><title>Welcome</title></head><body><h1>Hello World</h1></body></html>' | sudo tee /usr/share/nginx/html/index.html
