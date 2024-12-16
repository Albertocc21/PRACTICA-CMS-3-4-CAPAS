sudo apt-get update -y
sudo apt-get install -y nginx


cat <<EOF > /etc/nginx/sites-available/default
upstream backend_servers {
    server 192.168.42.11;
    server 192.168.42.12;
}

server {
    listen 80;
    server_name localhost;

    location / {
        proxy_pass http://backend_servers;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
    }
}

EOF


sudo systemctl restart nginx