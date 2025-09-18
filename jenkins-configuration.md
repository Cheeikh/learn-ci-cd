# Configuration Jenkins - Guide Complet

## 📋 Prérequis

### 1. Installation Jenkins
```bash
# Sur Ubuntu/Debian
sudo apt update
sudo apt install openjdk-11-jdk
wget -q -O - https://pkg.jenkins.io/debian/jenkins.io.key | sudo apt-key add -
sudo sh -c 'echo deb https://pkg.jenkins.io/debian binary/ > /etc/apt/sources.list.d/jenkins.list'
sudo apt update
sudo apt install jenkins

# Sur macOS avec Homebrew
brew install jenkins
```

### 2. Démarrage Jenkins
```bash
# Démarrage du service
sudo systemctl start jenkins
sudo systemctl enable jenkins

# Ou sur macOS
brew services start jenkins
```

## 🔧 Configuration Initiale

### 1. Accès à Jenkins
- URL : `http://localhost:8080`
- Mot de passe initial : `/var/lib/jenkins/secrets/initialAdminPassword`

### 2. Installation des Plugins Requis
Installer ces plugins via **Manage Jenkins > Manage Plugins** :

#### Plugins Essentiels
- ✅ **NodeJS Plugin** - Support Node.js
- ✅ **Docker Plugin** - Intégration Docker
- ✅ **Git Plugin** - Support Git
- ✅ **Pipeline Plugin** - Pipelines déclaratifs
- ✅ **Blue Ocean** - Interface moderne (optionnel)

## 🛠️ Configuration des Outils

### 1. Configuration NodeJS
**Manage Jenkins > Global Tool Configuration > NodeJS**

```
Name: NodeJS
Install automatically: ✅
Version: NodeJS 20.x (ou plus récent)
```

### 2. Configuration Docker
**Manage Jenkins > Global Tool Configuration > Docker**

```
Name: Docker
Install automatically: ✅
Version: Latest stable
```

## 🔐 Configuration des Credentials

### 1. Credentials Docker Hub
**Manage Jenkins > Manage Credentials > Global > Add Credentials**

```
Kind: Username with password
Scope: Global
Username: [VOTRE_USERNAME_DOCKERHUB]
Password: [VOTRE_PASSWORD_DOCKERHUB]
ID: dockerhub-credentials
Description: Docker Hub Credentials
```

### 2. Credentials GitHub (OBLIGATOIRE pour repo privé)
**Repository privé** - Configuration requise :
```
Kind: Username with password
Scope: Global
Username: [VOTRE_USERNAME_GITHUB]
Password: [VOTRE_PERSONAL_ACCESS_TOKEN]
ID: github-credentials
Description: GitHub Credentials for Private Repo
```

#### 🔑 Création d'un Personal Access Token GitHub :
1. GitHub > Settings > Developer settings > Personal access tokens > Tokens (classic)
2. Generate new token (classic)
3. Scopes requis :
   - ✅ `repo` (Full control of private repositories)
   - ✅ `read:org` (Read org and team membership)
4. Copier le token généré

## 📦 Création du Job Pipeline

### 1. Nouveau Job
- **New Item** > **Pipeline** > Nom : `learn-ci-cd`

### 2. Configuration du Pipeline
**Pipeline > Definition : Pipeline script from SCM**

```
SCM: Git
Repository URL: https://github.com/cheikhmbacke/learn-ci-cd.git
Branch Specifier: */main
Script Path: Jenkinsfile
```

### 3. Triggers (optionnel)
**Build Triggers > Poll SCM**
```
Schedule: H/5 * * * *  (toutes les 5 minutes)
```

## 🚀 Pipeline Détaillé

### Structure du Pipeline
```groovy
pipeline {
    agent any                    // Utilise n'importe quel agent disponible
    
    tools {
        nodejs "NodeJS"         // Utilise l'outil NodeJS configuré
    }
    
    stages {
        // Étapes du pipeline...
    }
    
    post {
        // Actions post-build...
    }
}
```

### Étapes Détaillées

#### 1. Checkout
```groovy
stage('Checkout') {
    steps {
        git branch: 'main', url: 'https://github.com/cheikhmbacke/learn-ci-cd.git'
    }
}
```
- **Objectif** : Récupère le code source depuis GitHub
- **Action** : Clone le repository sur l'agent Jenkins

#### 2. Install Dependencies
```groovy
stage('Install dependencies') {
    steps {
        sh 'npm install'
    }
}
```
- **Objectif** : Installe les dépendances npm
- **Action** : Exécute `npm install` pour installer les packages

#### 3. Build
```groovy
stage('Build') {
    steps {
        sh 'npm run build'
    }
}
```
- **Objectif** : Construit l'application avec Vite
- **Action** : Exécute `npm run build` (TypeScript + Vite)

#### 4. Test
```groovy
stage('Test') {
    steps {
        sh 'npm test -- --watchAll=false'
    }
}
```
- **Objectif** : Exécute les tests unitaires
- **Action** : Lance les tests avec Jest (mode CI)

#### 5. Docker Build
```groovy
stage('Docker Build') {
    steps {
        script {
            def image = docker.build("${env.JOB_NAME}:${env.BUILD_NUMBER}")
            docker.withRegistry('', 'dockerhub-credentials') {
                image.push()
                image.push('latest')
            }
        }
    }
}
```
- **Objectif** : Construit et pousse l'image Docker
- **Action** : 
  - Construit l'image avec le nom du job et numéro de build
  - Se connecte à Docker Hub avec les credentials
  - Pousse l'image avec le tag du build et 'latest'

#### 6. Deploy
```groovy
stage('Deploy') {
    steps {
        echo '🚀 Déploiement terminé - Image Docker disponible'
        echo "Image: ${env.JOB_NAME}:${env.BUILD_NUMBER}"
    }
}
```
- **Objectif** : Confirme le déploiement
- **Action** : Affiche les informations de l'image créée

## 🔄 Actions Post-Build

### Nettoyage
```groovy
post {
    always {
        cleanWs()              // Nettoie l'espace de travail
    }
    success {
        echo '✅ Pipeline réussi !'
    }
    failure {
        echo '❌ Pipeline échoué !'
    }
}
```

## 📊 Variables d'Environnement

### Variables Disponibles
- `env.JOB_NAME` : Nom du job Jenkins
- `env.BUILD_NUMBER` : Numéro du build
- `env.WORKSPACE` : Chemin de l'espace de travail
- `env.BUILD_URL` : URL du build

### Exemple d'Utilisation
```groovy
echo "Build: ${env.BUILD_NUMBER}"
echo "Job: ${env.JOB_NAME}"
echo "Workspace: ${env.WORKSPACE}"
```

## 🐳 Configuration Docker

### Dockerfile Utilisé
```dockerfile
FROM node:20-alpine AS build
WORKDIR /app
COPY package*.json ./
RUN npm install
COPY . .
RUN npm run build

FROM nginx:alpine
COPY --from=build /app/dist /usr/share/nginx/html
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
```

### Images Générées
- `learn-ci-cd:1` (build #1)
- `learn-ci-cd:2` (build #2)
- `learn-ci-cd:latest` (dernière version)

## 🔍 Débogage et Monitoring

### Logs
- **Console Output** : Logs détaillés de chaque étape
- **Build History** : Historique des builds
- **Pipeline Steps** : Vue détaillée des étapes

### Notifications
- **Email** : Configuration dans **Manage Jenkins > Configure System**
- **Slack** : Plugin Slack pour notifications
- **Webhook** : Notifications vers d'autres systèmes

## 🚨 Résolution de Problèmes

### Erreurs Communes

#### 1. NodeJS non trouvé
```
Solution: Vérifier la configuration NodeJS dans Global Tool Configuration
```

#### 2. Docker non accessible
```
Solution: Ajouter l'utilisateur Jenkins au groupe docker
sudo usermod -aG docker jenkins
```

#### 3. Credentials Docker Hub invalides
```
Solution: Vérifier les credentials dans Manage Credentials
```

#### 4. Git clone échoue
```
Solution: Vérifier les permissions et l'URL du repository
```

## 📈 Optimisations

### 1. Cache npm
```groovy
stage('Install dependencies') {
    steps {
        sh 'npm ci --cache .npm'
    }
}
```

### 2. Cache Docker
```groovy
stage('Docker Build') {
    steps {
        script {
            def image = docker.build("${env.JOB_NAME}:${env.BUILD_NUMBER}", "--cache-from ${env.JOB_NAME}:latest .")
        }
    }
}
```

### 3. Build en parallèle
```groovy
parallel {
    stage('Test') {
        steps { sh 'npm test' }
    }
    stage('Lint') {
        steps { sh 'npm run lint' }
    }
}
```

## 🎯 Prochaines Étapes

1. **Tests automatisés** : Ajouter des tests unitaires
2. **Quality Gates** : Intégrer SonarQube
3. **Déploiement automatique** : Déploiement vers staging/production
4. **Monitoring** : Intégration avec Prometheus/Grafana
5. **Notifications** : Slack/Email notifications

---

## 📝 Checklist de Configuration

- [ ] Jenkins installé et démarré
- [ ] Plugins NodeJS et Docker installés
- [ ] Outil NodeJS configuré
- [ ] Credentials Docker Hub ajoutés
- [ ] Job Pipeline créé
- [ ] Repository GitHub accessible
- [ ] Premier build réussi

---

*Configuration créée pour le projet learn-ci-cd - Prêt pour la production ! 🚀*
