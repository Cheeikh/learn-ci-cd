# 🐳 Configuration Docker Hub pour Jenkins

## ❌ Problème Identifié

### Erreur de Push
```
push access denied, repository does not exist or may require authorization: server message: insufficient_scope: authorization failed
```

### Cause du Problème
- **Nom d'image incorrect** : `learn-ci-cd:23` au lieu de `username/learn-ci-cd:23`
- **Repository inexistant** : Tentative de push vers `docker.io/library/learn-ci-cd`
- **Permissions insuffisantes** : Pas d'autorisation pour le repository public

## ✅ Solution Appliquée

### 1. **Utilisation du Nom d'Utilisateur Docker Hub**
```groovy
// AVANT (problématique)
sh "docker build -t ${env.JOB_NAME}:${env.BUILD_NUMBER} ."
sh "docker push ${env.JOB_NAME}:${env.BUILD_NUMBER}"

// APRÈS (corrigé)
withCredentials([usernamePassword(credentialsId: 'dockerhub-credentials', usernameVariable: 'DOCKER_USERNAME', passwordVariable: 'DOCKER_PASSWORD')]) {
    sh "docker build -t ${env.DOCKER_USERNAME}/${env.JOB_NAME}:${env.BUILD_NUMBER} ."
    sh "docker push ${env.DOCKER_USERNAME}/${env.JOB_NAME}:${env.BUILD_NUMBER}"
}
```

### 2. **Structure des Images Docker**
```
Format: username/repository:tag

Exemples:
- cheikhmbacke/learn-ci-cd:23
- cheikhmbacke/learn-ci-cd:latest
- monusername/monrepo:1.0.0
```

## 🔧 Configuration Requise

### **1. Credentials Jenkins**
```
Manage Jenkins > Manage Credentials > Global > Add Credentials
Kind: Username with password
Username: [VOTRE_USERNAME_DOCKERHUB]
Password: [VOTRE_PASSWORD_DOCKERHUB]
ID: dockerhub-credentials
```

### **2. Repository Docker Hub**
- ✅ **Repository public** : `username/learn-ci-cd`
- ✅ **Permissions** : Push autorisé pour l'utilisateur
- ✅ **Création automatique** : Le repository sera créé au premier push

### **3. Pipeline Optimisé**
```groovy
stage('Docker Build') {
    steps {
        script {
            // Login Docker Hub
            withCredentials([usernamePassword(credentialsId: 'dockerhub-credentials', usernameVariable: 'DOCKER_USERNAME', passwordVariable: 'DOCKER_PASSWORD')]) {
                sh 'echo $DOCKER_PASSWORD | docker login -u $DOCKER_USERNAME --password-stdin'
                
                // Build avec nom d'utilisateur
                sh "docker build -t ${env.DOCKER_USERNAME}/${env.JOB_NAME}:${env.BUILD_NUMBER} ."
                sh "docker tag ${env.DOCKER_USERNAME}/${env.JOB_NAME}:${env.BUILD_NUMBER} ${env.DOCKER_USERNAME}/${env.JOB_NAME}:latest"
                
                // Push
                sh "docker push ${env.DOCKER_USERNAME}/${env.JOB_NAME}:${env.BUILD_NUMBER}"
                sh "docker push ${env.DOCKER_USERNAME}/${env.JOB_NAME}:latest"
            }
        }
    }
}
```

## 🚀 Résultat Attendu

### **Images Générées**
```
Docker Hub Repository: https://hub.docker.com/r/username/learn-ci-cd

Tags disponibles:
- username/learn-ci-cd:23 (build #23)
- username/learn-ci-cd:24 (build #24)
- username/learn-ci-cd:latest (toujours la dernière)
```

### **Utilisation des Images**
```bash
# Pull de l'image
docker pull username/learn-ci-cd:latest

# Exécution
docker run -p 80:80 username/learn-ci-cd:latest
```

## 🔍 Dépannage

### **Erreur: Repository does not exist**
```
Solution: Le repository sera créé automatiquement au premier push
```

### **Erreur: Authorization failed**
```
Solution: Vérifier les credentials Docker Hub dans Jenkins
```

### **Erreur: Push access denied**
```
Solution: Vérifier que l'utilisateur a les permissions de push
```

## 📊 Avantages de la Solution

### **Sécurité**
- ✅ **Credentials sécurisés** : Stockés dans Jenkins
- ✅ **Variables d'environnement** : Pas d'exposition des mots de passe
- ✅ **Authentification** : Login automatique avant push

### **Flexibilité**
- ✅ **Nom d'utilisateur dynamique** : Utilise les credentials configurés
- ✅ **Repository automatique** : Création au premier push
- ✅ **Tags multiples** : Build number + latest

### **Monitoring**
- ✅ **Logs détaillés** : Affichage du nom complet de l'image
- ✅ **URL du repository** : Lien direct vers Docker Hub
- ✅ **Statut de push** : Confirmation de succès

## 🔗 Ressources

- [Docker Hub Documentation](https://docs.docker.com/docker-hub/)
- [Jenkins Credentials Plugin](https://plugins.jenkins.io/credentials/)
- [Docker Build and Push](https://docs.docker.com/engine/reference/commandline/push/)

---

*Configuration Docker Hub optimisée - Push réussi ! 🐳✅*
