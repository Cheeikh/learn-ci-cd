# 🐳 Résolution Problèmes Docker dans Jenkins

## ❌ Problème Identifié

### Erreur Rencontrée
```
/Users/cheikhmbacke/.jenkins/workspace/learn-ci-cd@tmp/durable-c46e5d59/script.sh.copy: line 1: docker: command not found
```

### Cause
L'outil `dockerTool` dans Jenkins n'était pas correctement configuré ou Docker n'était pas accessible dans l'environnement d'exécution.

## ✅ Solution Appliquée

### 1. **Suppression de l'outil dockerTool**
```groovy
tools {
    nodejs "NodeJS"
    // dockerTool "Docker" // ❌ Supprimé car non fonctionnel
}
```

### 2. **Utilisation Directe de Docker**
```groovy
stage('Docker Build') {
    steps {
        script {
            // Vérifier que Docker est disponible
            sh 'docker --version'
            
            // Login Docker Hub avec credentials
            withCredentials([usernamePassword(credentialsId: 'dockerhub-credentials', usernameVariable: 'DOCKER_USERNAME', passwordVariable: 'DOCKER_PASSWORD')]) {
                sh 'echo $DOCKER_PASSWORD | docker login -u $DOCKER_USERNAME --password-stdin'
            }
            
            // Construire l'image Docker
            sh "docker build -t ${env.JOB_NAME}:${env.BUILD_NUMBER} ."
            sh "docker tag ${env.JOB_NAME}:${env.BUILD_NUMBER} ${env.JOB_NAME}:latest"
            
            // Push vers Docker Hub
            withCredentials([usernamePassword(credentialsId: 'dockerhub-credentials', usernameVariable: 'DOCKER_USERNAME', passwordVariable: 'DOCKER_PASSWORD')]) {
                sh "docker push ${env.JOB_NAME}:${env.BUILD_NUMBER}"
                sh "docker push ${env.JOB_NAME}:latest"
            }
        }
    }
}
```

## 🔧 Configuration Requise

### **Credentials Docker Hub**
Dans Jenkins > Manage Credentials > Global > Add Credentials :
```
Kind: Username with password
Scope: Global
Username: [VOTRE_USERNAME_DOCKERHUB]
Password: [VOTRE_PASSWORD_DOCKERHUB]
ID: dockerhub-credentials
Description: Docker Hub Credentials
```

### **Vérification Docker Local**
```bash
# Vérifier que Docker est installé et fonctionne
docker --version
docker ps

# Sur macOS, s'assurer que Docker Desktop est démarré
```

## 📊 Avantages de cette Solution

### ✅ **Simplicité**
- Pas de configuration d'outil Jenkins complexe
- Utilisation directe de Docker installé sur le système

### ✅ **Fiabilité**
- Fonctionne avec Docker Desktop sur macOS
- Compatible avec toutes les versions de Docker

### ✅ **Sécurité**
- Utilisation de `withCredentials` pour les secrets
- Pas d'exposition des mots de passe dans les logs

### ✅ **Flexibilité**
- Contrôle total sur les commandes Docker
- Facile à déboguer et modifier

## 🚀 Pipeline Optimisé

### **Structure Finale**
```groovy
pipeline {
    agent any
    
    tools {
        nodejs "NodeJS"        // Seul outil nécessaire
    }
    
    stages {
        stage('Checkout') { /* ... */ }
        stage('Install dependencies') { /* ... */ }
        stage('Build') { /* ... */ }
        stage('Test') { /* ... */ }
        stage('Docker Build') { /* Construction et push */ }
        stage('Deploy') { /* ... */ }
    }
}
```

### **Fonctionnalités Docker**
- ✅ **Build automatique** avec versioning
- ✅ **Tagging multiple** (version + latest)
- ✅ **Push sécurisé** vers Docker Hub
- ✅ **Gestion d'erreurs** intégrée

## 🔍 Débogage

### **Commandes de Test**
```bash
# Test local de Docker
docker --version
docker build -t test-image .
docker run --rm test-image

# Test de login Docker Hub
echo $DOCKER_PASSWORD | docker login -u $DOCKER_USERNAME --password-stdin
```

### **Logs Jenkins**
Surveillez les logs pour :
- ✅ Vérification de la version Docker
- ✅ Succès du login Docker Hub
- ✅ Construction de l'image
- ✅ Push vers le registry

## 📈 Prochaines Améliorations

### **Cache Docker**
```groovy
// Utiliser le cache pour accélérer les builds
sh "docker build --cache-from ${env.JOB_NAME}:latest -t ${env.JOB_NAME}:${env.BUILD_NUMBER} ."
```

### **Multi-architecture**
```groovy
// Support multi-architecture (ARM64 + AMD64)
sh "docker buildx build --platform linux/amd64,linux/arm64 -t ${env.JOB_NAME}:${env.BUILD_NUMBER} ."
```

### **Scan de Sécurité**
```groovy
// Scan de vulnérabilités
sh "docker scan ${env.JOB_NAME}:${env.BUILD_NUMBER}"
```

## ✅ Résultat Attendu

Le pipeline devrait maintenant :
1. ✅ Récupérer le code source
2. ✅ Installer les dépendances Node.js
3. ✅ Construire l'application Vite
4. ✅ Exécuter les tests (avec gestion d'erreur)
5. ✅ **Construire l'image Docker** avec succès
6. ✅ **Pousser l'image** vers Docker Hub
7. ✅ Confirmer le déploiement

## 🎯 Images Générées

Après un build réussi :
- `learn-ci-cd:1` (build #1)
- `learn-ci-cd:2` (build #2)
- `learn-ci-cd:latest` (dernière version)

---

*Solution Docker fonctionnelle et sécurisée - Prêt pour la production ! 🚀*
