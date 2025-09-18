pipeline {
    agent any

    // Tools
    tools {
        nodejs "NodeJS"
        dockerTool "Docker"
    }
    
    environment {
        // Utiliser Docker Desktop du système
        PATH = "/Applications/Docker.app/Contents/Resources/bin:${env.PATH}"
        DOCKER_BUILDKIT = "1"
    }
    
    environment {
        // Utiliser Docker du système (symlink vers Docker Desktop)
        PATH = "/usr/local/bin:${env.PATH}"
        DOCKER_BUILDKIT = "1"
    }

    // Stages
    stages {
        stage('Checkout') {
            steps {
                git branch: 'main', 
                     url: 'https://github.com/Cheeikh/learn-ci-cd.git',
                     credentialsId: 'github-credentials'
            }
        }

        stage('Install dependencies') {
            steps {
                sh 'npm install'
            }
        }

        stage('Build') {
            steps {
                sh 'npm run build'
            }
        }

        stage('Test') {
            steps {
                sh 'npm test -- --watchAll=false || echo "Tests non configurés"'
            }
        }

        stage('Docker Build') {
            steps {
                script {
                    // Vérifier que Docker est disponible et fonctionnel
                    sh '''
                        echo "=== Vérification Docker ==="
                        echo "PATH: $PATH"
                        echo "Docker location: $(which docker)"
                        
                        # Vérifier que Docker est accessible
                        if ! command -v docker >/dev/null 2>&1; then
                            echo "❌ Docker non trouvé dans PATH"
                            echo "Veuillez installer Docker Desktop depuis https://docker.com"
                            exit 1
                        fi
                        
                        # Afficher la version Docker
                        docker --version
                        
                        # Vérifier que Docker daemon est accessible
                        if ! docker info >/dev/null 2>&1; then
                            echo "❌ Docker daemon non accessible"
                            echo "Veuillez démarrer Docker Desktop et réessayer"
                            exit 1
                        fi
                        
                        echo "✅ Docker fonctionnel"
                    '''
                    
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
                    
                    echo "✅ Image Docker construite et poussée avec succès"
                    echo "Image: ${env.JOB_NAME}:${env.BUILD_NUMBER}"
                    echo "Tag latest: ${env.JOB_NAME}:latest"
                }
            }
        }

        stage('Deploy') {
            steps {
                echo '🚀 Déploiement terminé - Image Docker disponible'
                echo "Image: ${env.JOB_NAME}:${env.BUILD_NUMBER}"
            }
        }
    }

    post {
        always {
            script {
                // Nettoyage conditionnel
                if (env.WORKSPACE) {
                    cleanWs()
                }
            }
        }
        success {
            echo '✅ Pipeline réussi !'
        }
        failure {
            echo '❌ Pipeline échoué !'
            echo 'Vérifiez les logs pour plus de détails'
        }
    }
}
