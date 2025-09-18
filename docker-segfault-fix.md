# 🐳 Résolution du Problème Docker Segmentation Fault

## ❌ Problème Identifié

### Erreur Rencontrée
```
Segmentation fault: 11 docker --version
```

### Cause du Problème
- **Jenkins** télécharge Docker pour architecture **x86_64**
- **macOS Apple Silicon** (ARM64) ne peut pas exécuter ce binaire
- **Incompatibilité d'architecture** → Segmentation fault

## ✅ Solution Appliquée

### 1. **Suppression de l'Outil Docker Jenkins**
```groovy
// AVANT (problématique)
tools {
    nodejs "NodeJS"
    dockerTool "Docker"  // ❌ Cause segmentation fault
}

// APRÈS (corrigé)
tools {
    nodejs "NodeJS"     // ✅ Seulement NodeJS
}
```

### 2. **Utilisation de Docker Desktop du Système**
```groovy
environment {
    // Utiliser Docker Desktop du système
    PATH = "/Applications/Docker.app/Contents/Resources/bin:${env.PATH}"
    DOCKER_BUILDKIT = "1"
}
```

### 3. **Vérification Docker Desktop**
```groovy
stage('Docker Build') {
    steps {
        script {
            sh '''
                echo "=== Vérification Docker Desktop ==="
                
                # Vérifier que Docker Desktop est installé
                if [ ! -f "/Applications/Docker.app/Contents/Resources/bin/docker" ]; then
                    echo "❌ Docker Desktop non trouvé"
                    exit 1
                fi
                
                # Vérifier que Docker Desktop est démarré
                if ! docker ps >/dev/null 2>&1; then
                    echo "❌ Docker Desktop n'est pas démarré"
                    exit 1
                fi
                
                docker --version
                echo "✅ Docker Desktop fonctionnel"
            '''
        }
    }
}
```

## 🛠️ Configuration Requise

### **Prérequis**
1. **Docker Desktop** installé sur macOS
2. **Docker Desktop démarré** avant le build Jenkins
3. **Permissions** pour l'utilisateur Jenkins

### **Installation Docker Desktop**
```bash
# Via Homebrew
brew install --cask docker

# Ou téléchargement direct
# https://docker.com/products/docker-desktop/
```

### **Vérification Installation**
```bash
# Vérifier que Docker Desktop est installé
ls -la /Applications/Docker.app/Contents/Resources/bin/docker

# Vérifier que Docker fonctionne
docker --version
docker ps
```

## 🔧 Alternatives

### **Option 1: Docker Desktop (Recommandé)**
- ✅ **Compatible ARM64** (Apple Silicon)
- ✅ **Interface graphique** pour monitoring
- ✅ **Facile à installer** et configurer
- ✅ **Intégration native** macOS

### **Option 2: Docker via Homebrew**
```bash
# Installation Docker CLI uniquement
brew install docker

# Nécessite un daemon Docker (Docker Desktop ou Docker Machine)
```

### **Option 3: Agent Docker Dédié**
```groovy
pipeline {
    agent {
        docker {
            image 'node:20-alpine'
            args '-u root:root'
        }
    }
    // Pipeline dans un conteneur
}
```

## 🚨 Dépannage

### **Docker Desktop Non Trouvé**
```
❌ Docker Desktop non trouvé
```
**Solution** :
1. Installer Docker Desktop
2. Redémarrer Jenkins
3. Relancer le build

### **Docker Desktop Non Démarré**
```
❌ Docker Desktop n'est pas démarré
```
**Solution** :
1. Démarrer Docker Desktop
2. Attendre que le daemon soit prêt
3. Vérifier avec `docker ps`

### **Permissions Insuffisantes**
```
permission denied while trying to connect to the Docker daemon socket
```
**Solution** :
1. Ajouter l'utilisateur au groupe docker
2. Redémarrer la session
3. Ou utiliser `sudo` (non recommandé)

## 📊 Avantages de la Solution

### **Performance**
- ✅ **Pas de téléchargement** Docker par Jenkins
- ✅ **Utilisation native** du système
- ✅ **Cache Docker** partagé

### **Compatibilité**
- ✅ **Architecture ARM64** supportée
- ✅ **macOS native** integration
- ✅ **Pas de segmentation fault**

### **Maintenance**
- ✅ **Mise à jour** via Docker Desktop
- ✅ **Configuration centralisée**
- ✅ **Monitoring** via interface graphique

## 🔗 Ressources

- [Docker Desktop pour Mac](https://docs.docker.com/desktop/mac/install/)
- [Apple Silicon Support](https://docs.docker.com/desktop/mac/apple-silicon/)
- [Jenkins Docker Plugin](https://plugins.jenkins.io/docker/)

---

*Problème résolu - Docker fonctionnel sur Apple Silicon ! 🍎🐳*
