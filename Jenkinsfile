pipeline {
    agent { label 'agent-jenkins' } // Remplace par le label réel de ton agent Jenkins

    environment {
        IMAGE_NAME = 'cynthia783/post'
        TAG = 'latest'
        DOCKER_HUB_CREDENTIALS = 'dockerhub-post-id' // ID à configurer dans Jenkins
        SONARQUBE = 'sonarqube'
    }

    stages {
        stage('Checkout Code') {
            steps {
                git credentialsId: 'my-git-token-ok', branch: 'main', url: 'https://github.com/cynthia783/post.git'
            }
        }

    stage('SonarQube Analysis') {
        steps {
            script {
                // Lancer l'analyse SonarQube sur le code source
                sonarScanner(
                    installation: "${SONARQUBE}", // Utiliser l'installation SonarQube configurée dans Jenkins
                    options: [
                        "-Dsonar.projectKey=my_project_key",  // Remplace par la clé de ton projet SonarQube
                        "-Dsonar.projectName=My Project",     // Nom de ton projet dans SonarQube
                        "-Dsonar.sources=."                   // Analyser le répertoire courant (src)
                    ]
                )
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
