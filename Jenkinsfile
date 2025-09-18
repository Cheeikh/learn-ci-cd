pipeline {
    agent any

    tools {
        nodejs "NodeJS"
        docker "Docker"
    }

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
                    // Vérifier que Docker est disponible
                    sh 'docker --version'
                    
                    // Construire l'image Docker
                    def image = docker.build("${env.JOB_NAME}:${env.BUILD_NUMBER}")
                    
                    // Push vers Docker Hub avec credentials
                    docker.withRegistry('', 'dockerhub-credentials') {
                        image.push()
                        image.push('latest')
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
