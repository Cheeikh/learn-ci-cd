# 🔒 Configuration Repository Privé GitHub

## 🎯 Objectif
Configurer Jenkins pour accéder à un repository GitHub privé en toute sécurité.

## 🔑 Étape 1: Création du Personal Access Token GitHub

### 1.1 Accès aux Settings GitHub
1. Connectez-vous à GitHub
2. Cliquez sur votre avatar (coin supérieur droit)
3. Sélectionnez **Settings**

### 1.2 Navigation vers les Tokens
1. Dans le menu gauche : **Developer settings**
2. Cliquez sur **Personal access tokens**
3. Sélectionnez **Tokens (classic)**

### 1.3 Génération du Token
1. Cliquez sur **Generate new token**
2. Sélectionnez **Generate new token (classic)**

### 1.4 Configuration du Token
```
Note: Jenkins CI/CD Access
Expiration: 90 days (ou selon votre politique)
Scopes:
  ✅ repo (Full control of private repositories)
    ✅ repo:status
    ✅ repo_deployment
    ✅ public_repo
    ✅ repo:invite
    ✅ security_events
  ✅ read:org (Read org and team membership)
```

### 1.5 Copie du Token
⚠️ **IMPORTANT** : Copiez immédiatement le token généré. Il ne sera plus affiché !

## 🔐 Étape 2: Configuration Jenkins

### 2.1 Accès aux Credentials
1. Jenkins > **Manage Jenkins**
2. **Manage Credentials**
3. **Global** (ou un domaine spécifique)
4. **Add Credentials**

### 2.2 Configuration des Credentials
```
Kind: Username with password
Scope: Global
Username: [VOTRE_USERNAME_GITHUB]
Password: [LE_TOKEN_GÉNÉRÉ]
ID: github-credentials
Description: GitHub Credentials for Private Repo
```

### 2.3 Validation
- ✅ **ID** doit être exactement `github-credentials`
- ✅ **Username** : votre nom d'utilisateur GitHub
- ✅ **Password** : le Personal Access Token (PAS votre mot de passe GitHub)

## 📝 Étape 3: Vérification du Jenkinsfile

### 3.1 Configuration Actuelle
```groovy
stage('Checkout') {
    steps {
        git branch: 'main', 
             url: 'https://github.com/cheikhmbacke/learn-ci-cd.git',
             credentialsId: 'github-credentials'
    }
}
```

### 3.2 Points Importants
- ✅ **credentialsId** doit correspondre à l'ID configuré dans Jenkins
- ✅ **URL** : utilise HTTPS (pas SSH)
- ✅ **Branch** : spécifie la branche principale

## 🧪 Étape 4: Test de Configuration

### 4.1 Premier Build
1. Lancez un build manuel
2. Surveillez l'étape **Checkout**
3. Vérifiez que le code est récupéré sans erreur

### 4.2 Logs de Vérification
```
[Pipeline] stage
[Pipeline] { (Checkout)
[Pipeline] git
Fetching changes from the remote Git repository
Checking out Revision abc123... (main)
```

## 🚨 Résolution de Problèmes

### Erreur: "Could not read from remote repository"

#### Cause 1: Credentials incorrects
```
Solution: Vérifier l'ID et les credentials dans Jenkins
```

#### Cause 2: Token expiré
```
Solution: Générer un nouveau Personal Access Token
```

#### Cause 3: Permissions insuffisantes
```
Solution: Vérifier les scopes du token (repo, read:org)
```

### Erreur: "Authentication failed"

#### Cause: Mauvaise configuration
```
Solution: 
1. Vérifier le username (pas l'email)
2. Utiliser le token comme password (pas le mot de passe GitHub)
3. Vérifier l'ID des credentials
```

## 🔒 Sécurité

### Bonnes Pratiques
1. **Token avec expiration** : 90 jours maximum
2. **Scopes minimaux** : Seulement `repo` et `read:org`
3. **Rotation régulière** : Renouveler les tokens
4. **Monitoring** : Surveiller l'utilisation des tokens

### Gestion des Tokens
1. **Documentation** : Noter la date de création
2. **Révocation** : Révocable depuis GitHub si compromis
3. **Backup** : Garder une copie sécurisée des credentials

## 📊 Alternatives

### Option 1: SSH Keys (Plus sécurisé)
```groovy
stage('Checkout') {
    steps {
        git branch: 'main', 
             url: 'git@github.com:cheikhmbacke/learn-ci-cd.git',
             credentialsId: 'github-ssh-key'
    }
}
```

### Option 2: GitHub App (Enterprise)
- Plus approprié pour les organisations
- Gestion centralisée des permissions
- Audit trail complet

## ✅ Checklist de Configuration

- [ ] Personal Access Token créé avec les bons scopes
- [ ] Credentials configurés dans Jenkins avec l'ID correct
- [ ] Jenkinsfile modifié pour utiliser les credentials
- [ ] Premier build testé avec succès
- [ ] Token documenté et sécurisé
- [ ] Plan de rotation des tokens établi

## 🔗 Liens Utiles

- [GitHub Personal Access Tokens](https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/creating-a-personal-access-token)
- [Jenkins Credentials Plugin](https://plugins.jenkins.io/credentials/)
- [Git Plugin Documentation](https://plugins.jenkins.io/git/)

---

*Configuration sécurisée pour repository privé - Prêt pour la production ! 🔒*
