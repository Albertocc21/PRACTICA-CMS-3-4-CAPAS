# PRACTICA-CMS-3-4-CAPAS

## Índice

1. #### **[Introducción de la práctica](#introducción)**

2. #### **[Estructura](#estructura-de-la-infraestructura)**     

3. #### **[Explicación direccionamiento ip](#direccionamiento-ip)**

4. #### **[Despliegue de la infraestructura](#despliegue)**  

5. #### **[Scripts aprovisionamiento](#scripts)**
   - *[Provision del balanceador](#script-del-balanceador)*
   - *[Provision del servidor web1](#script-servidores-web)*
   - *[Provision del servidor NFS](#script-nfs)*
   - *[Provision del servidor BBDD](#script-bbdd)* 

## Introducción

En esta práctica, implementaremos un CMS (OwnCloud o Joomla) sobre una infraestructura de alta disponibilidad. La infraestructura se basa en una pila LEMP (Linux, Nginx, MariaDB, PHP-FPM) y se organiza en tres capas: balanceador de carga, servidores web y NFS y base de datos. 

El despliegue se realizará utilizando **Vagrant** (con box de Debian) y **VirtualBox**, asegurando que las capas 2 y 3 no estén expuestas a la red pública. Todo el aprovisionamiento de las máquinas se hará mediante ficheros que automatizarán la instalación y modificación de estas.

## Estructura de la Infraestructura

La infraestructura contará con 3 capas que contendrán:

- **Capa 1: Balanceador de carga**
  - Servicio: Nginx configurado como balanceador de carga.

- **Capa 2: Servidores**
  - Servicios: Nginx y PHP-FPM desde un almacenamiento compartido proporcionado por un servidor NFS.

- **Capa 3: Servidor BBDD**
  - Servicio: MariaDB.

## Direccionamiento IP

| Servidor                | IP                           | Descripción                                                           |
|-------------------------|------------------------------|-----------------------------------------------------------------------|
| `balanceadorAlberto`    | 192.168.30.10/192.168.40.10  | Balanceador de carga, red pública y red interna                       |
| `serverweb1Alberto`     | 192.168.40.11/192.168.50.11  | Servidor web 1, red interna y red interna BBDD                        |
| `serverweb2Alberto`     | 192.168.40.12/192.168.50.12  | Servidor web 2, red interna y red interna BBDD                        |
| `serverNFSAlberto`      | 192.168.40.13/192.168.50.13  | Servidor NFS y PHP-FPM, red interna y red interna BBDD                |
| `serverdatosAlberto`    | 192.168.50.10                | Servidor BBDD, red interna.                                           |

### Capa 1: Balanceador de carga
- **Servidor:** `balanceadorAlberto`  
- **IP:** `192.168.30.10` (red pública) y `192.168.40.10` (red interna).   
  - La **IP pública (192.168.30.10)** permite que los clientes accedan al servicio desde Internet.  
  - La **IP interna (192.168.40.10)** se utiliza para comunicarse con los servidores web en la capa 2, garantizando que las comunicaciones internas no sean accesibles desde el exterior.

### Capa 2: Servidores web y NFS
Esta capa contiene los servidores web que procesan las solicitudes del balanceador y ejecutan las aplicaciones del CMS.

- **Servidor web1:** `serverweb1Alberto` con ip `192.168.40.11`.  
- **Servidor web2:** `serverweb2Alberto` con ip `192.168.40.12`.
- **Servidor NFS:** `serverNFSAlberto` con IP `192.168.40.13`.  
- **Red:** Los servidores están en la red interna `192.168.40.0/24` y también tienen acceso a la red `192.168.50.0/24`, que es donde se encuentra el servidor de base de datos.   
  - Reciben las solicitudes balanceadas desde `balanceadorAlberto`.  
  - Acceden a los archivos compartidos en `serverNFSAlberto`.  
  - Procesan aplicaciones dinámicas utilizando el motor PHP-FPM alojado en `serverNFSAlberto`. 
  - `serverNFSAlberto` proporciona almacenamiento compartido mediante NFS para los servidores web.  
  - Aloja el motor PHP-FPM para el procesamiento de scripts PHP de los servidores web.  
  - Además, los servidores web y `serverNFSAlberto` tienen comunicación con el servidor de base de datos `serverdatosAlberto` en la red `192.168.50.0/24` para manejar consultas de la base de datos.


### Capa 3: BBDD
- **Servidor:** `serverdatosAlberto` con IP `192.168.50.10`.  
- **Red:** Utiliza otra subred interna `192.168.50.0/24`.   
  - Aloja la base de datos MariaDB que almacena toda la información del CMS.  
  - Se comunica únicamente con los servidores web de la capa 2 para manejar consultas.

## Despliegue


## Scripts

#### Script del balanceador

#### Script servidores web

#### Script NFS

#### Script BBDD
