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