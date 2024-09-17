pipeline {
    agent any 
    tools {
        maven 'maven-app'  
    }
    stages {
        stage("Build Jar") {
            steps {
                script {
                    echo "Building the app..."
                    sh 'mvn package'
                }
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    echo "Building Docker image..."
                    // Define a variable for the Docker image name
                    def dockerImage = 'myapplicationdeployments.azurecr.io/maven-app:6.0'
                    sh "docker build -t ${dockerImage} ."
                }
            }
        }

        stage('Scan Docker Image'){
            steps {
                script {
                    echo 'Scanning Docker image...'
                    def dockerImage = 'myapplicationdeployments.azurecr.io/maven-app:6.0' // Use the same image name
                    sh "trivy image --exit-code 1 --severity high,critical ${dockerImage}"
                }
            }  
        }

        stage('Push Docker Image to Azure Container Registry') {
            steps {
                script {
                    echo "Pushing Docker image to ACR..."
                    withCredentials([usernamePassword(credentialsId: 'azure-cr-credentials', passwordVariable: 'PASSWORD', usernameVariable: 'USERNAME')]) {
                        def dockerImage = 'myapplicationdeployments.azurecr.io/maven-app:6.0' // Use the same image name
                        sh "docker login -u ${USERNAME} -p ${PASSWORD} myapplicationdeployments.azurecr.io"
                        sh "docker push ${dockerImage}"
                    }
                }
            }
        }

        stage("Deploy") {
            steps {
                echo "Deploying the app..."
            }
        }
    }

    post {
        success {
            echo 'Pipeline completed successfully!'
        }
        failure {
            echo 'Pipeline failed!'
        }
    }
}
