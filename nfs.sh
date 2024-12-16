sudo apt-get update -y
sudo apt-get install -y nfs-kernel-server php7.4 php7.4-fpm php7.4-mysql php7.4-gd php7.4-xml php7.4-mbstring php7.4-curl php7.4-zip php7.4-intl php7.4-ldap unzip


mkdir -p /var/www/html
sudo chown -R www-data:www-data /var/www/html
sudo chmod -R 755 /var/www/html


echo "/var/www/html 192.168.42.11(rw,sync,no_subtree_check)" >> /etc/exports
echo "/var/www/html 192.168.42.12(rw,sync,no_subtree_check)" >> /etc/exports


exportfs -a
sudo systemctl restart nfs-kernel-server

cd /tmp
sudo wget https://download.owncloud.com/server/stable/owncloud-10.9.1.zip
unzip owncloud-10.9.1.zip
sudo mv owncloud /var/www/html/


sudo chown -R www-data:www-data /var/www/html/owncloud
sudo chmod -R 755 /var/www/html/owncloud


cat <<EOF > /var/www/html/owncloud/config/autoconfig.php
<?php
\$AUTOCONFIG = array(
  "dbtype" => "mysql",
  "dbname" => "db_owncloud",
  "dbuser" => "alberto",
  "dbpassword" => "1234",
  "dbhost" => "192.168.52.10",
  "directory" => "/var/www/html/owncloud/data",
  "adminlogin" => "admin1234",
  "adminpass" => "1234"
);
EOF

echo "Añadiendo dominios de confianza a la configuración de OwnCloud..."
php -r "
  \$configFile = '/var/www/html/owncloud/config/config.php';
  if (file_exists(\$configFile)) {
    \$config = include(\$configFile);
    \$config['trusted_domains'] = array(
      'localhost',
      '192.168.42.10',
      '192.168.42.11',
      '192.168.42.12',
    );
    file_put_contents(\$configFile, '<?php return ' . var_export(\$config, true) . ';');
  } else {
    echo 'No se pudo encontrar el archivo config.php';
  }
"


sed -i 's/^listen = .*/listen = 192.168.42.13:9000/' /etc/php/7.4/fpm/pool.d/www.conf

sudo systemctl restart php7.4-fpm

sudo ip route del default