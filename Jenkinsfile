pipeline {
    agent { label 'agent-jenkins' } // Remplace par le label réel de ton agent Jenkins

    environment {
        IMAGE_NAME = 'cynthia783/post'
        TAG = 'latest'
        DOCKER_HUB_CREDENTIALS = 'dockerhub-post-id' // ID à configurer dans Jenkins
        SONARQUBE = 'sonarqube'
        SONAR_TOKEN = credentials('sonar-token-test')
        KUBERNETES_CLUSTER = 'minikube'  // Utilisation de Minikube comme cluster Kubernetes
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

        stage(' Trivy Analysis - Docker Image - Report HTML') {
            steps {
                script {
                sh '''
                    trivy image --exit-code 0 \
                    --format template \
                    --template "@/usr/local/share/trivy/templates/html.tpl" \
                    -o trivy-report.html ${IMAGE_NAME}:${TAG}
                '''
                }
                archiveArtifacts artifacts: 'trivy-report.html', allowEmptyArchive: true
                publishHTML(target: [
                    reportName: 'Trivy Scan Report',
                    reportDir: '.',
                    reportFiles: 'trivy-report.html',
                    keepAll: true,
                    alwaysLinkToLastBuild: true,
                    allowMissing: false
                ])

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

        stage('Deploy to Kubernetes (Minikube)') {
            steps {
                script {
                    // Démarre Minikube si ce n'est pas déjà fait
                    sh 'minikube start'

                    // Configure l'environnement Kubernetes pour Minikube
                    sh 'eval $(minikube -p minikube docker-env)'

                    // Appliquer les fichiers YAML pour configurer les permissions RBAC avant le déploiement
                    sh '''
                    kubectl apply -f k8s/node-access-role.yaml
                    kubectl apply -f k8s/node-access-binding.yaml
                    '''

                    // Appliquer le ConfigMap
                    sh 'kubectl apply -f k8s/configmap.yaml'

                    // Appliquer les fichiers Kubernetes (deployment et service)
                    sh 'kubectl apply -f k8s/deploiement.yaml'
                    sh 'kubectl apply -f k8s/service.yaml'
                }
            }
        }

        stage('Check Deployment') {
            steps {
                script {
                    // Vérifie si les pods sont en cours d'exécution
                    sh 'kubectl get pods'
                }
            }
        }

        stage('Check if Report Changed and Push to GitHub') {
            steps {
                script {
                    // Clone the repository
                    sh 'git clone https://github.com/cynthia783/post.git'
                    dir('post') {
                        // Copie le rapport de vulnerability de trivy sur le repo git
                        sh 'cp ../trivy-report.html ./trivy-report.html'
                        
                        // Check si le contenu du rapport a changé en le comparant par la précédente version
                        def reportChanged = sh(script: "git diff --exit-code trivy-report.html", returnStatus: true)
                        
                        if (reportChanged != 0) {
                            echo 'Report has changed, committing and pushing...'
                            // Ajouter le changement sur git
                            sh 'git add trivy-report.html'
                            sh 'git commit -m "Update Trivy report" || echo "No changes to commit"'
                            // Push le changement sur git
                            sh 'git push origin main'
                        } else {
                            echo 'No changes in the report, skipping commit.'
                        }
                    }
                }
            }
        }

        /*stage('Deploy with docker-compose') {
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
        }*/
    }

    post {
        success {
            echo "Déploiement terminé avec succès !"
        }
        failure {
            echo "Le pipeline a échoué. Vérifie les logs."
        }
        always {
            archiveArtifacts artifacts: 'trivy-report.html', fingerprint: true
        }
    }
}
