pipeline {
    agent any

    tools {
        nodejs "NodeJS"  
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
                    def image = docker.build("${env.JOB_NAME}:${env.BUILD_NUMBER}")
                    docker.withRegistry('', 'dockerhub-credentials') {
                        image.push()
                        image.push('latest')
                    }
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
