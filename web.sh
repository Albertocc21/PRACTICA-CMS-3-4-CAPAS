sudo apt-get update -y
sudo apt-get install -y nginx nfs-common php7.4 php7.4-fpm php7.4-mysql php7.4-gd php7.4-xml php7.4-mbstring php7.4-curl php7.4-zip php7.4-intl php7.4-ldap mariadb-client

mkdir -p /var/www/html


sudo mount -t nfs 192.168.42.13:/var/www/html /var/www/html


echo "192.168.42.13:/var/www/html /var/www/html nfs defaults 0 0" >> /etc/fstab


cat <<EOF > /etc/nginx/sites-available/default
server {
    listen 80;

    root /var/www/html/owncloud;
    index index.php index.html index.htm;

    location / {
        try_files \$uri \$uri/ /index.php?\$query_string;
    }

    location ~ \.php\$ {
        include snippets/fastcgi-php.conf;
        fastcgi_pass 192.168.42.13:9000;
        fastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name;
        include fastcgi_params;
    }

    location ~ ^/(?:\.htaccess|data|config|db_structure\.xml|README) {
        deny all;
    }
}
EOF

nginx -t


sudo systemctl restart nginx

sudo systemctl restart php7.4-fpm

sudo ip route del default