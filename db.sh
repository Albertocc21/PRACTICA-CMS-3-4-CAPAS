sudo apt-get update -y
sudo apt-get install -y mariadb-server


sed -i 's/bind-address.*/bind-address = 192.168.52.10/' /etc/mysql/mariadb.conf.d/50-server.cnf

sudo systemctl restart mariadb

mysql -u root <<EOF
CREATE DATABASE db_owncloud;
CREATE USER 'alberto'@'192.168.52.%' IDENTIFIED BY '1234';
GRANT ALL PRIVILEGES ON db_owncloud.* TO 'alberto'@'192.168.52.%';
FLUSH PRIVILEGES;
EOF

sudo ip route del default