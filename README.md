# PRACTICA-CMS-3-4-CAPAS

## Requisitos
- Tener Vagrant y VirtualBox.
- ISO Debian.
- Automatización de máquinas

## Índice

1. #### **[Introducción de la práctica](#introducción)**

2. #### **[Estructura](#estructura-de-la-infraestructura)**     

3. #### **[Explicación direccionamiento red](#direccionamiento-red)**

4. #### **[Vagrantfile y Scripts aprovisionamiento](#vagrantfile-y-scripts)**
   - *[Vagrantfile](#vagrantfile)*
   - *[Aprovisionamiento del balanceador](#script-del-balanceador)*
   - *[Aprovisionamiento del servidor web1](#script-servidores-web)*
   - *[Aprovisionamiento del servidor NFS](#script-nfs)*
   - *[Aprovisionamiento del servidor BBDD](#script-bbdd)* 

5. #### **[Resultado](#resultado-owncloud)**



## Introducción

En esta práctica, implementaremos un CMS (OwnCloud) sobre una infraestructura de alta disponibilidad. La infraestructura se basa en una pila LEMP (Linux, Nginx, MariaDB, PHP-FPM) y se organiza en tres capas: balanceador de carga, servidores web y NFS y base de datos. 

El despliegue se realizará utilizando **Vagrant** (con box de Debian), asegurando que las capas 2 y 3 no estén expuestas a la red pública. Todo el aprovisionamiento de las máquinas se hará mediante ficheros que automatizarán la instalación y modificación de estas.

## Estructura de la Infraestructura

La infraestructura contará con 3 capas que contendrán:

- **Capa 1: Balanceador de carga**
  - Servicio: Nginx configurado como balanceador de carga.

- **Capa 2: Servidores**
  - Servicios: Nginx y PHP-FPM desde un almacenamiento compartido proporcionado por un servidor NFS.

- **Capa 3: Servidor BBDD**
  - Servicio: MariaDB.

## Direccionamiento red

| Servidor                | IP                           | Descripción                                                           |
|-------------------------|------------------------------|-----------------------------------------------------------------------|
| `balanceadorAlberto`    | IP pública/192.168.42.10     | Balanceador de carga, red pública y red interna                       |
| `serverweb1Alberto`     | 192.168.42.11/192.168.52.11  | Servidor web 1, red interna y red interna BBDD                        |
| `serverweb2Alberto`     | 192.168.42.12/192.168.52.12  | Servidor web 2, red interna y red interna BBDD                        |
| `serverNFSAlberto`      | 192.168.42.13/192.168.52.13  | Servidor NFS y PHP-FPM, red interna y red interna BBDD                |
| `serverdatosAlberto`    | 192.168.52.10                | Servidor BBDD, red interna.                                           |

### Capa 1: Balanceador de carga

- **Servidor:** `balanceadorAlberto`  
- **IP:** (red pública de la máquina) y `192.168.42.10` (red interna).   
  - La **IP pública** permite que los clientes accedan al servicio desde Internet.  
  - La **IP interna (192.168.42.10)** se utiliza para comunicarse con los servidores web en la capa 2, garantizando que las comunicaciones internas no sean accesibles desde el exterior.

### Capa 2: Servidores web y NFS

- **Servidor web1:** `serverweb1Alberto` con ip `192.168.42.11`.  
- **Servidor web2:** `serverweb2Alberto` con ip `192.168.42.12`.
- **Servidor NFS:** `serverNFSAlberto` con IP `192.168.42.13`.  
- **Red:** Los servidores están en la red interna `192.168.42.0/24` y también tienen acceso a la red `192.168.52.0/24`, que es donde se encuentra el servidor de base de datos.   
  - Reciben las solicitudes balanceadas desde `balanceadorAlberto`.  
  - Acceden a los archivos compartidos en `serverNFSAlberto`.  
  - Procesan aplicaciones dinámicas utilizando el motor PHP-FPM alojado en `serverNFSAlberto`. 
  - `serverNFSAlberto` proporciona almacenamiento compartido mediante NFS para los servidores web.  
  - Aloja el motor PHP-FPM para el procesamiento de scripts PHP de los servidores web.  
  - Además, los servidores web y `serverNFSAlberto` tienen comunicación con el servidor de base de datos `serverdatosAlberto` en la red `192.168.52.0/24` para manejar consultas de la base de datos.


### Capa 3: BBDD

- **Servidor:** `serverdatosAlberto` con IP `192.168.52.10`.  
- **Red:** Utiliza otra subred interna `192.168.52.0/24`.   
  - Aloja la base de datos MariaDB que almacena toda la información del CMS.  
  - Se comunica únicamente con los servidores web de la capa 2 para manejar consultas.


## Vagrantfile y Scripts

### Vagrantfile
```bash
Vagrant.configure("2") do |config|
# Configuración global
config.vm.box = "debian/bullseye64"
        # BBDD
    config.vm.define "serverdatosAlberto" do |database|
        database.vm.hostname = "serverdatosAlberto"
        database.vm.network "private_network", ip: "192.168.52.10", virtualbox_intnet: "red_privadaBBDD"               # Red interna BBDD 
        database.vm.provision "shell", path: "db.sh"
    end

        # Servidor NFS
    config.vm.define "serverNFSAlberto" do |nfs|
        nfs.vm.hostname = "serverNFSAlberto"
        nfs.vm.network "private_network", ip: "192.168.42.13", virtualbox_intnet: "red_privada"                        # Red interna
        nfs.vm.network "private_network", ip: "192.168.52.13", virtualbox_intnet: "red_privadaBBDD"                    # Red interna BBDD
        nfs.vm.provision "shell", path: "nfs.sh"
    end
    
        # Servidor web1
    config.vm.define "serverweb1Alberto" do |webserver1|
        webserver1.vm.hostname = "serverweb1Alberto"
        webserver1.vm.network "private_network", ip: "192.168.42.11", virtualbox_intnet: "red_privada"                   # Red interna
        webserver1.vm.network "private_network", ip: "192.168.52.11", virtualbox_intnet: "red_privadaBBDD"               # Red interna BBDD
        webserver1.vm.provision "shell", path: "web.sh"
    end
    
        # Servidor web2
    config.vm.define "serverweb2Alberto" do |webserver2|
        webserver2.vm.hostname = "serverweb2Alberto"
        webserver2.vm.network "private_network", ip: "192.168.42.12", virtualbox_intnet: "red_privada"                  # Red interna
        webserver2.vm.network "private_network", ip: "192.168.52.12", virtualbox_intnet: "red_privadaBBDD"              # Red interna BBDD
        webserver2.vm.provision "shell", path: "web.sh"
    end
    # Balanceador
    config.vm.define "balanceadorAlberto" do |balanceador|
        balanceador.vm.hostname = "balanceadorAlberto"
        balanceador.vm.network "public_network"   # Red pública
        balanceador.vm.network "private_network", ip: "192.168.42.10", virtualbox_intnet: "red_privada"                  # Red interna
        balanceador.vm.provision "shell", path: "balanceador.sh"
    end
end
```

### Script del balanceador
```bash
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
```
**sudo apt-get update -y:** Actualiza la lista de paquetes.

**sudo apt-get install -y nginx:** Instala el servidor web Nginx.

**cat <<EOF > /etc/nginx/sites-available/default:** Crea y escribe la configuración del servidor web Nginx para que actúe como un balanceador de carga. La configuración especifica dos servidores backend (con las ips `192.168.42.11` y `192.168.42.12`) que recibirán las solicitudes de los clientes.

**sudo systemctl restart nginx:** Reinicia el servicio Nginx.

### Script servidores web
```bash
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
```
**sudo apt update:** Actualiza la lista de paquetes.

**sudo apt-get install -y nginx nfs-common php7.4 php7.4-fpm php7.4-mysql php7.4-gd php7.4-xml php7.4-mbstring php7.4-curl php7.4-zip php7.4-intl php7.4-ldap mariadb-client::** Instala Nginx, el cliente NFS, varias extensiones de PHP necesarias y el cliente MariaDB

**mkdir -p /var/www/html:** Crea el directorio `/var/www/html` si no existe.

**sudo mount -t nfs 192.168.42.13:/var/www/html /var/www/html:** Monta el directorio `/var/www/html` desde el servidor NFS con la IP `192.168.41.13`.

**echo "192.168.42.13:/var/www/html /var/www/html nfs defaults 0 0" >> /etc/fstab:** Añade la configuración de montaje NFS al archivo `/etc/fstab` para que se monte automáticamente en el inicio del sistema.

**cat <<EOF > /etc/nginx/sites-available/default:** Crea y configura un archivo de configuración para el servidor web Nginx.

**nginx -t:** Verifica la configuración de Nginx para asegurarse de que no haya errores de sintaxis.

**sudo systemctl restart nginx:** Reinicia el servicio Nginx.

**sudo systemctl restart php7.4-fpm:** Reinicia el servicio PHP-FPM.

**sudo ip route del default:** Elimina la ruta de la puerta de enlace por defecto.

### Script NFS
```bash
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
```
**sudo apt-get update -y:** Actualiza la lista de paquetes.

**sudo apt-get install -y nfs-kernel-server php7.4 php7.4-fpm php7.4-mysql php7.4-gd php7.4-xml php7.4-mbstring php7.4-curl php7.4-zip php7.4-intl php7.4-ldap unzip:** Instala el servidor NFS y varias extensiones de PHP necesarias.

**mkdir -p /var/www/html:** Crea el directorio `/var/www/html`.

**sudo chown -R www-data:www-data /var/www/html:** Asigna el propietario del directorio a `www-data`.

**sudo chmod -R 755 /var/www/html:** Aplica permisos de lectura, escritura y ejecución al directorio.

**echo "/var/www/html 192.168.42.11(rw,sync,no_subtree_check)" >> /etc/exports:** Configura el directorio `/var/www/html` para ser exportado al cliente con la ip `192.168.41.11`.

**echo "/var/www/html 192.168.42.12(rw,sync,no_subtree_check)" >> /etc/exports:** Configura el mismo directorio para el cliente con la ip `192.168.41.12`.

**exportfs -a:** Exporta las configuraciones del servidor NFS.

**sudo systemctl restart nfs-kernel-server:** Reinicia el servicio NFS.

**cd /tmp:** Entra al directorio `/tmp`.

**sudo wget https://download.owncloud.com/server/stable/owncloud-10.9.1.zip:** Descarga el archivo de instalación de OwnCloud.

**unzip owncloud-10.9.1.zip:** Descomprime el contenido del archivo Owncloud.

**sudo mv owncloud /var/www/html/:** Mueve el directorio de OwnCloud a `/var/www/html`.

**sudo chown -R www-data:www-data /var/www/html/owncloud:** Asigna el propietario del directorio de OwnCloud a `www-data`.

**sudo chmod -R 755 /var/www/html/owncloud:** Aplica permisos de lectura, escritura y ejecución al directorio de OwnCloud.

**cat <<EOF > /var/www/html/owncloud/config/autoconfig.php:** Crea y escribe un archivo de configuración automática para OwnCloud.

**sed -i 's/^listen = .*/listen = 192.168.42.13:9000/' /etc/php/7.4/fpm/pool.d/www.conf:** Modifica el archivo de configuración de PHP-FPM.

**sudo systemctl restart php7.4-fpm:** Reinicia el servicio PHP-FPM.

**sudo ip route del default:** Elimina la ruta de la puerta de enlace por defecto.

### Script BBDD
```bash
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
```
**sudo apt-get update -y:** Actualiza la lista de paquetes.

**sudo apt-get install -y mariadb-server:** Instala el servidor de base de datos MariaDB.

**sed -i 's/bind-address.*/bind-address = 192.168.52.10/' /etc/mysql/mariadb.conf.d/50-server.cnf:** Cambia la configuración de MariaDB para aceptar conexiones desde la IP 192.168.52.10.

**sudo systemctl restart mariadb:** Reinicia el servicio de MariaDB.

**mysql -u root <<EOF:** Accede al servidor MariaDB como usuario root.

**CREATE DATABASE db_owncloud;:** Crea una base de datos.

**CREATE USER 'alberto'@'192.168.52.%' IDENTIFIED BY '1234';:** Crea un usuario alberto con acceso desde la subred 192.168.52.0/24 y la contraseña 1234.

<b>GRANT ALL PRIVILEGES ON db_owncloud.* TO 'alberto'@'192.168.52.%';:</b> Concede a alberto permisos completos sobre la base de datos db_owncloud.

**FLUSH PRIVILEGES;:** Aplica los cambios de privilegios en el servidor MariaDB.

**sudo ip route del default**: Elimina la ruta de puerta de enlace predeterminada.

## Resultado OwnCloud
**_El mapeo de puertos no funciona por y es por esto que accedemos por una ip pública._**

**Tenemos que mirar la ip del balanceador(en mi caso 192.168.0.27).**
![ip a](https://github.com/user-attachments/assets/c9fdf3c4-3431-465f-a96b-6c1e9231bcd9)


**En el navegador buscamos ```http://ipbalanceador/owncloud y nos direige directamente al login, donde tendremos que poner nombre del admin y su contraseña.**
![owncloud log](https://github.com/user-attachments/assets/e21b4393-889e-4fa8-bfcb-e9de99b6ab4e)


**Una vez introducido las credenciales, nos redirige dentro de OwnCloud.**
![owncloud archivos](https://github.com/user-attachments/assets/4754146b-9cb6-4d29-823b-f7597bdf2698)


