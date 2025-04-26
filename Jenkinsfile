pipeline {
    agent { label 'agent-jenkins' } // Remplace par le label réel de ton agent Jenkins

    environment {
        IMAGE_NAME = 'cynthia783/post'
        TAG = 'latest'
        DOCKER_HUB_CREDENTIALS = 'dockerhub-post-id' // ID à configurer dans Jenkins
        SONARQUBE = 'sonarqube'
        SONAR_TOKEN = credentials('sonar-token-test')
    }

    stages {
        stage('Checkout Code') {
            steps {
                git credentialsId: 'my-git-token-ok', branch: 'main', url: 'https://github.com/cynthia783/post.git'
            }
        }

    stage('SonarQube Analysis - code source') {
        steps {
            withSonarQubeEnv('SonarQube') {
                withCredentials([string(credentialsId: 'sonar-token-test', variable: 'SONAR_TOKEN')]) {
                    sh """
                        sonar-scanner \
                        -Dsonar.projectKey=post \
                        -Dsonar.sources=. \
                        -Dsonar.host.url=http://192.168.128.142:9000 \
                        -Dsonar.login=${SONAR_TOKEN}
                    """
                }
            }
        }
    }

    stage('Clean old images') {
        steps {
            script {
                sh 'docker system prune -f'
            }
        }
    }


        stage('Build Docker Image') {
            steps {
                script {
                    sh 'docker build -t ${IMAGE_NAME}:${TAG} .'
                }
            }
        }

        stage('SonarQube Analysis - Docker Image') {
            steps {
                script {
                    // Utilisation de Trivy ou un autre scanner pour analyser l'image Docker
                    // Exemple avec Trivy pour scanner la sécurité de l'image Docker
                    sh 'trivy image --exit-code 1 --severity HIGH,CRITICAL ${IMAGE_NAME}:${TAG}'
                }
            }
        }

        /*stage('Push Docker Image') {
            steps {
                withDockerRegistry([credentialsId: DOCKER_HUB_CREDENTIALS, url: '']) {
                    script {
                        docker.image("${IMAGE_NAME}:${TAG}").push()
                    }
                }
            }
        }*/

        stage('Deploy with docker-compose') {
            steps {
                script {
                    // Redémarre les conteneurs avec la nouvelle image
                    sh '''
                        docker-compose down
                        docker-compose pull
                        docker-compose up -d
                    '''
                }
            }
        }
    }

    post {
        success {
            echo "Déploiement terminé avec succès !"
        }
        failure {
            echo "Le pipeline a échoué. Vérifie les logs."
        }
    }
}
