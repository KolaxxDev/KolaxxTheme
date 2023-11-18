#!/bin/bash

if (( $EUID != 0 )); then
    echo "Veuillez exécuter en tant que root"
    exit
fi

clear

installTheme(){
    cd /var/www/
    tar -cvf KolaxxThemebackup.tar.gz pterodactyl
    echo "Installation du thème..."
    cd /var/www/pterodactyl
    rm -r KolaxxTheme
    git clone https://github.com/KolaxxDev/KolaxxTheme.git
    cd KolaxxTheme
    rm /var/www/pterodactyl/resources/scripts/KolaxxTheme.css
    rm /var/www/pterodactyl/resources/scripts/index.tsx
    mv index.tsx /var/www/pterodactyl/resources/scripts/index.tsx
    mv KolaxxTheme.css /var/www/pterodactyl/resources/scripts/KolaxxTheme.css
    cd /var/www/pterodactyl

    curl -sL https://deb.nodesource.com/setup_18.x | sudo -E bash -
    apt update
    apt install -y nodejs

    npm i -g yarn
    yarn

    cd /var/www/pterodactyl
    yarn build:production
    sudo php artisan optimize:clear


}

installThemeQuestion(){
    while true; do
        read -p "Voulez-vous vraiment installer le thème [y/n]? " yn
        case $yn in
            [Yy]* ) installTheme; break;;
            [Nn]* ) exit;;
            * ) echo "Veuillez répondre par yes ou par no.";;
        esac
    done
}

repair(){
    bash <(curl https://raw.githubusercontent.com/KolaxxDev/KolaxxTheme/master/repair.sh)
}

restoreBackUp(){
    echo "Restauration de la sauvegarde..."
    cd /var/www/
    tar -xvf KolaxxThemebackup.tar.gz
    rm KolaxxThemebackup.tar.gz

    cd /var/www/pterodactyl
    yarn build:production
    sudo php artisan optimize:clear
}
echo "Copyright (c) 2023 Kolaxx | kolaxx.fr"
echo "Ce programme est un logiciel libre : vous pouvez le redistribuer et/ou le modifier"
echo ""
echo "Website: https://kolaxx.fr"
echo ""
echo "[1] Installer le thème"
echo "[2] Restaurer la sauvegarde"
echo "[3] Réparer le panel (à utiliser si vous avez une erreur dans l’installation du thème)"
echo "[4] Annuler"

read -p "Veuillez saisir un numéro: " choice
if [ $choice == "1" ]
    then
    installThemeQuestion
fi
if [ $choice == "2" ]
    then
    restoreBackUp
fi
if [ $choice == "3" ]
    then
    repair
fi
if [ $choice == "4" ]
    then
    exit
fi
