#!/bin/bash

# 🚀 Script d'installation et configuration Jenkins pour learn-ci-cd
# Compatible Ubuntu/Debian et macOS

set -e  # Arrêter en cas d'erreur

echo "🔧 Installation et configuration Jenkins pour learn-ci-cd"
echo "=================================================="

# Fonction pour détecter l'OS
detect_os() {
    # Comme on est déjà sur macOS, on définit directement l'OS
    OS="macos"
    echo "📱 OS détecté: $OS (macOS)"
}

# Installation Jenkins selon l'OS
demarrer_jenkins() {
    # Démarrage du service
    brew services start jenkins
    
    echo "✅ Jenkins installé avec succès!"
}

# Configuration Docker
setup_docker() {
    echo "🐳 Configuration Docker..."
    
    # Vérification de Docker
    if ! command -v docker &> /dev/null; then
        echo "📦 Installation de Docker..."
        
        case $OS in
            "ubuntu")
                # Installation Docker
                curl -fsSL https://get.docker.com -o get-docker.sh
                sudo sh get-docker.sh
                sudo usermod -aG docker $USER
                ;;
            "macos")
                # Docker Desktop pour macOS
                brew install --cask docker
                echo "⚠️  Veuillez installer Docker Desktop depuis l'App Store ou https://docker.com"
                ;;
        esac
    fi
    
}

# Installation des plugins Jenkins
install_plugins() {
    echo "🔌 Installation des plugins Jenkins..."
    
    # Attendre que Jenkins soit démarré
    echo "⏳ Attente du démarrage de Jenkins..."
    sleep 30
    
    # URL Jenkins
    JENKINS_URL="http://localhost:8080"
    
    # Mot de passe initial
    if [[ $OS == "ubuntu" || $OS == "centos" ]]; then
        JENKINS_PASSWORD=$(sudo cat /var/lib/jenkins/secrets/initialAdminPassword)
    else
        JENKINS_PASSWORD=$(cat ~/.jenkins/secrets/initialAdminPassword 2>/dev/null || echo "Veuillez récupérer le mot de passe initial")
    fi
    
    echo "🔑 Mot de passe initial Jenkins: $JENKINS_PASSWORD"
    echo "🌐 Accédez à: $JENKINS_URL"
    
    # Liste des plugins à installer
    PLUGINS="nodejs docker git pipeline blueocean"
    
    echo "📋 Plugins à installer: $PLUGINS"
    echo "⚠️  Veuillez installer ces plugins manuellement via l'interface Jenkins"
}

# Configuration des outils
setup_tools() {
    echo "🛠️  Configuration des outils..."
    
    cat << EOF

📋 Configuration manuelle requise dans Jenkins:

1. 🌐 Accédez à http://localhost:8080
2. 🔑 Utilisez le mot de passe initial affiché ci-dessus
3. 🔌 Installez les plugins suggérés
4. 👤 Créez un utilisateur administrateur
5. 🛠️  Configurez les outils:

   Manage Jenkins > Global Tool Configuration:
   
   NodeJS:
   - Name: NodeJS
   - Install automatically: ✅
   - Version: NodeJS 20.x
   
   Docker:
   - Name: Docker  
   - Install automatically: ✅
   - Version: Latest stable

6. 🔐 Ajoutez les credentials GitHub (REPOSITORY PRIVÉ):
   
   Manage Jenkins > Manage Credentials > Global > Add Credentials:
   - Kind: Username with password
   - Username: [VOTRE_USERNAME_GITHUB]
   - Password: [VOTRE_PERSONAL_ACCESS_TOKEN]
   - ID: github-credentials
   
   🔑 Créer un Personal Access Token GitHub:
   - GitHub > Settings > Developer settings > Personal access tokens
   - Scopes: repo, read:org

7. 🔐 Ajoutez les credentials Docker Hub:
   
   Manage Jenkins > Manage Credentials > Global > Add Credentials:
   - Kind: Username with password
   - Username: [VOTRE_USERNAME_DOCKERHUB]
   - Password: [VOTRE_PASSWORD_DOCKERHUB]  
   - ID: dockerhub-credentials

8. 📦 Créez un nouveau job Pipeline:
   
   New Item > Pipeline > Nom: learn-ci-cd
   Pipeline > Definition: Pipeline script from SCM
   SCM: Git
   Repository URL: https://github.com/cheikhmbacke/learn-ci-cd.git
   Branch: */main
   Script Path: Jenkinsfile

EOF
}

# Vérification des prérequis
check_prerequisites() {
    echo "🔍 Vérification des prérequis..."
    
    # Vérification de l'accès root/sudo
    if ! sudo -n true 2>/dev/null; then
        echo "❌ Privilèges sudo requis"
        exit 1
    fi
    
    # Vérification de la connectivité
    if ! curl -s https://pkg.jenkins.io > /dev/null; then
        echo "❌ Connectivité internet requise"
        exit 1
    fi
    
    echo "✅ Prérequis validés"
}

# Fonction principale
main() {
    echo "🚀 Démarrage de l'installation Jenkins..."
    
    detect_os
    check_prerequisites
    demarrer_jenkins
    setup_docker
    install_plugins
    setup_tools
    
    echo ""
    echo "🎉 Installation terminée!"
    echo "========================="
    echo "🌐 Jenkins: http://localhost:8080"
    echo "📚 Documentation: jenkins-configuration.md"
    echo "🔄 Pipeline: Jenkinsfile"
    echo ""
    echo "📋 Prochaines étapes:"
    echo "1. Accédez à l'interface Jenkins"
    echo "2. Configurez les outils et credentials"
    echo "3. Créez le job Pipeline"
    echo "4. Lancez votre premier build!"
    echo ""
    echo "🚀 Votre projet learn-ci-cd est prêt pour Jenkins!"
}

# Exécution du script
main "$@"
