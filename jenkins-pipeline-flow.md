# 🔄 Flux du Pipeline Jenkins

## Schéma du Pipeline CI/CD

```
┌─────────────────┐    ┌──────────────────┐    ┌─────────────────┐
│   GitHub Repo   │───▶│   Jenkins Job    │───▶│  Docker Hub     │
│                 │    │                  │    │                 │
│ learn-ci-cd     │    │ Pipeline CI/CD   │    │ Image Registry  │
└─────────────────┘    └──────────────────┘    └─────────────────┘
                              │
                              ▼
                    ┌──────────────────┐
                    │   Build Agent    │
                    │                  │
                    │ Node.js 20       │
                    │ Docker           │
                    │ Git              │
                    └──────────────────┘
```

## Étapes Détaillées du Pipeline

### 1️⃣ Checkout
```
┌─────────────────┐
│   Repository    │
│                 │
│ • Code source   │
│ • package.json  │
│ • Dockerfile    │
│ • Jenkinsfile   │
└─────────────────┘
         │
         ▼
┌─────────────────┐
│   Workspace     │
│                 │
│ /var/jenkins/   │
│ workspace/      │
│ learn-ci-cd/    │
└─────────────────┘
```

### 2️⃣ Install Dependencies
```
┌─────────────────┐
│   npm install   │
│                 │
│ • Vite 7.1.2    │
│ • TypeScript    │
│ • Dependencies  │
└─────────────────┘
         │
         ▼
┌─────────────────┐
│  node_modules/  │
│                 │
│ • Packages      │
│ • Cache npm     │
└─────────────────┘
```

### 3️⃣ Build
```
┌─────────────────┐
│   npm run build │
│                 │
│ • TypeScript    │
│ • Vite build    │
└─────────────────┘
         │
         ▼
┌─────────────────┐
│     dist/       │
│                 │
│ • index.html    │
│ • assets/       │
│ • CSS/JS        │
└─────────────────┘
```

### 4️⃣ Test
```
┌─────────────────┐
│   npm test      │
│                 │
│ • Jest          │
│ • Tests unit.   │
└─────────────────┘
         │
         ▼
┌─────────────────┐
│  Test Results   │
│                 │
│ ✅ Pass         │
│ ❌ Fail         │
└─────────────────┘
```

### 5️⃣ Docker Build
```
┌─────────────────┐
│  Docker Build   │
│                 │
│ • Multi-stage   │
│ • Node.js 20    │
│ • Nginx         │
└─────────────────┘
         │
         ▼
┌─────────────────┐
│   Docker Hub    │
│                 │
│ • Image tagged  │
│ • Versioned     │
│ • Latest        │
└─────────────────┘
```

## Variables d'Environnement

### Variables Jenkins
```bash
JOB_NAME=learn-ci-cd
BUILD_NUMBER=1, 2, 3...
WORKSPACE=/var/jenkins/workspace/learn-ci-cd
BUILD_URL=http://jenkins:8080/job/learn-ci-cd/1/
```

### Variables Docker
```bash
DOCKER_IMAGE=learn-ci-cd:1
DOCKER_REGISTRY=docker.io
DOCKER_TAG=latest
```

## Flux de Données

### Input
- Code source GitHub
- Configuration Jenkinsfile
- Credentials Docker Hub

### Processing
- Installation dépendances
- Build application
- Tests automatiques
- Construction image Docker

### Output
- Image Docker versionnée
- Logs de build
- Notifications de statut

## Gestion des Erreurs

### Points de Contrôle
1. **Checkout** : Repository accessible ?
2. **Dependencies** : npm install réussi ?
3. **Build** : Compilation TypeScript OK ?
4. **Tests** : Tous les tests passent ?
5. **Docker** : Image construite et poussée ?

### Actions de Récupération
- **Retry** : Relancer l'étape échouée
- **Clean** : Nettoyer et recommencer
- **Notify** : Alerter l'équipe
- **Rollback** : Utiliser la version précédente

## Métriques et Monitoring

### Temps d'Exécution
- Checkout : ~10s
- Dependencies : ~30s
- Build : ~15s
- Tests : ~20s
- Docker : ~60s
- **Total** : ~2-3 minutes

### Ressources
- CPU : 2 cores minimum
- RAM : 4GB minimum
- Disk : 10GB pour cache

## Intégrations

### Notifications
- **Email** : build@company.com
- **Slack** : #dev-notifications
- **Teams** : Dev Team Channel

### Webhooks
- **GitHub** : Trigger automatique
- **Docker Hub** : Scan de sécurité
- **Monitoring** : Métriques Prometheus
