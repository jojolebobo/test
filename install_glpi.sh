#!/bin/bash

### Configuration
# Version de l'agent à installer
AGENT_VERSION="1.11"

# Pour GLPI 10.x :
SERVER_ENDPOINT_URL="https://glpi.alara-group.fr/"
### /Configuration

### Choix de l'architecture
echo "Veuillez choisir l'architecture de votre machine :"
echo "1. Intel (x86_64)"
echo "2. Silicon (arm64)"
read -p "Entrez votre choix (1 ou 2) : " ARCH

if [ "$ARCH" -eq 1 ]; then
    agent_pkg_url="https://github.com/glpi-project/glpi-agent/releases/download/${AGENT_VERSION}/GLPI-Agent-${AGENT_VERSION}_x86_64.pkg"
elif [ "$ARCH" -eq 2 ]; then
    agent_pkg_url="https://github.com/glpi-project/glpi-agent/releases/download/${AGENT_VERSION}/GLPI-Agent-${AGENT_VERSION}_arm64.pkg"
else
    echo "Choix invalide. Veuillez relancer le script."
    exit 1
fi

### Récupération installateur et installation
cd "$(mktemp -d)"
curl -L --output glpi_agent.pkg "${agent_pkg_url}"
installer -pkg ./glpi_agent.pkg -target /Applications

rm glpi_agent.pkg
cd - > /dev/null
rmdir "${OLDPWD}"
### /Récupération installateur et installation

### Configuration de l'agent 
read -p "Veuillez entrer le trigramme : " TAG

cat > /Applications/GLPI-Agent/etc/conf.d/server.cfg <<EOT
server = ${SERVER_ENDPOINT_URL}
EOT

cat > /Applications/GLPI-Agent/etc/conf.d/communication.cfg <<EOT
lazy = 0
EOT

cat > /Applications/GLPI-Agent/etc/conf.d/inventory.cfg <<EOT
tag = ${TAG}
EOT
### /Configuration de l'agent

### Première exécution et inventaire

# Lancement service (mode "Managed")
# (faire un "launchctl stop …" au préalable si mise à jour depuis ancienne version)
launchctl start com.teclib.glpi-agent

# Demande d'inventaire
pkill -USR1 -f -P 1 glpi-agent

# Vérification prise en compte demande (facultatif)
ps aux | grep 'glp[i]'
### Première exécution et inventaire (mode "Managed")
