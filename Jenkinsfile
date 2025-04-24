pipeline {
    agent { label 'test-jenkins' } // Remplace par le label réel de ton agent Jenkins

    environment {
        IMAGE_NAME = 'cynthia783/postiz-custom'
        TAG = 'latest'
        DOCKER_HUB_CREDENTIALS = 'dockerhub-post-id' // ID à configurer dans Jenkins
    }

    stage('Checkout Code') {
        steps {
            //git credentialsId: 'my-git-token-ok', branch: 'main', url: 'https://github.com/cynthia783/post.git'
            git credentialsId: 'my-git-token-ok', branch: 'main', url: 'https://github.com/cynthia783/post.git'

        }
    }


        stage('Build Docker Image') {
            steps {
                script {
                    // Copie .env dans le contexte si nécessaire (optionnel si déjà dans le repo)
                    sh 'cp .env ./'

                    docker.build("${IMAGE_NAME}:${TAG}")
                }
            }
        }

        stage('Push Docker Image') {
            steps {
                withDockerRegistry([credentialsId: DOCKER_HUB_CREDENTIALS, url: '']) {
                    script {
                        docker.image("${IMAGE_NAME}:${TAG}").push()
                    }
                }
            }
        }

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
