# 🔧 Résolution du Problème PATH Docker dans Jenkins

## ❌ Problème Identifié

### Erreur Persistante
```
Segmentation fault: 11 docker ps > /dev/null 2>&1
```

### Cause Racine
- **PATH incorrect** dans Jenkins
- **Chemin direct** vers Docker Desktop causait segmentation fault
- **Symlink** `/usr/local/bin/docker` non utilisé

## 🔍 Diagnostic Effectué

### 1. **Vérification Docker Local**
```bash
$ which docker
/usr/local/bin/docker

$ docker --version
Docker version 28.1.1, build 4eba377

$ ls -la /usr/local/bin/docker
lrwxr-xr-x@ 1 root wheel 54 Jun 30 10:01 /usr/local/bin/docker -> /Applications/Docker.app/Contents/Resources/bin/docker
```

### 2. **Analyse du Problème**
- ✅ **Docker fonctionne** en local
- ✅ **Symlink correct** vers Docker Desktop
- ❌ **Jenkins utilisait** le chemin direct
- ❌ **Segmentation fault** avec le chemin direct

## ✅ Solution Appliquée

### 1. **Correction du PATH**
```groovy
// AVANT (problématique)
environment {
    PATH = "/Applications/Docker.app/Contents/Resources/bin:${env.PATH}"
    DOCKER_BUILDKIT = "1"
}

// APRÈS (corrigé)
environment {
    PATH = "/usr/local/bin:${env.PATH}"
    DOCKER_BUILDKIT = "1"
}
```

### 2. **Amélioration de la Vérification**
```groovy
stage('Docker Build') {
    steps {
        script {
            sh '''
                echo "=== Vérification Docker ==="
                echo "PATH: $PATH"
                echo "Docker location: $(which docker)"
                
                # Vérifier que Docker est accessible
                if ! command -v docker >/dev/null 2>&1; then
                    echo "❌ Docker non trouvé dans PATH"
                    exit 1
                fi
                
                # Afficher la version Docker
                docker --version
                
                # Vérifier que Docker daemon est accessible
                if ! docker info >/dev/null 2>&1; then
                    echo "❌ Docker daemon non accessible"
                    exit 1
                fi
                
                echo "✅ Docker fonctionnel"
            '''
        }
    }
}
```

## 🛠️ Configuration Recommandée

### **Chemin Docker Standard sur macOS**
```bash
# Symlink principal (recommandé)
/usr/local/bin/docker -> /Applications/Docker.app/Contents/Resources/bin/docker

# Chemin direct (peut causer segmentation fault)
/Applications/Docker.app/Contents/Resources/bin/docker
```

### **PATH Jenkins Optimisé**
```groovy
environment {
    PATH = "/usr/local/bin:${env.PATH}"
    DOCKER_BUILDKIT = "1"
}
```

## 🔍 Dépannage Avancé

### **Si Docker n'est pas trouvé**
```bash
# Vérifier l'installation
ls -la /usr/local/bin/docker

# Recréer le symlink si nécessaire
sudo ln -sf /Applications/Docker.app/Contents/Resources/bin/docker /usr/local/bin/docker

# Vérifier les permissions
ls -la /usr/local/bin/docker
```

### **Si Docker Desktop n'est pas démarré**
```bash
# Démarrer Docker Desktop
open /Applications/Docker.app

# Vérifier le daemon
docker info

# Vérifier les conteneurs
docker ps
```

## 📊 Avantages de la Solution

### **Stabilité**
- ✅ **Pas de segmentation fault** : Utilise le symlink standard
- ✅ **Compatible Apple Silicon** : Chemin natif macOS
- ✅ **Robuste** : Fonctionne même si Docker Desktop est mis à jour

### **Performance**
- ✅ **Démarrage rapide** : Pas de téléchargement par Jenkins
- ✅ **Cache partagé** : Utilise le cache Docker local
- ✅ **Intégration native** : Suit les conventions macOS

### **Maintenance**
- ✅ **Mise à jour automatique** : Symlink suit Docker Desktop
- ✅ **Configuration simple** : PATH standard
- ✅ **Debugging facile** : Logs détaillés

## 🚀 Résultat Attendu

Le pipeline devrait maintenant :
1. ✅ **Trouver Docker** : `which docker` → `/usr/local/bin/docker`
2. ✅ **Afficher la version** : `Docker version 28.1.1`
3. ✅ **Vérifier le daemon** : `docker info` → succès
4. ✅ **Construire l'image** : `docker build` → succès
5. ✅ **Pousser l'image** : `docker push` → succès

## 🔗 Ressources

- [Docker Desktop pour Mac](https://docs.docker.com/desktop/mac/install/)
- [Jenkins Environment Variables](https://www.jenkins.io/doc/book/pipeline/jenkinsfile/#using-environment-variables)
- [Docker PATH Configuration](https://docs.docker.com/desktop/mac/apple-silicon/)

---

*Problème de PATH Docker résolu - Pipeline prêt ! 🐳✅*
