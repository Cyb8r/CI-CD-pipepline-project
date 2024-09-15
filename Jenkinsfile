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
                    sh 'docker build -t myapplicationdeployments.azurecr.io/maven-app:6.0 .'
                }
            }
        }

        stage('Push Docker Image to Azure Container Registry') {
            steps {
                script {
                    echo "Pushing Docker image to ACR..."
                    withCredentials([usernamePassword(credentialsId: 'myapplicationmyapplicationdeployments.azurecr.io', passwordVariable: 'PASS', usernameVariable: 'USER')]) {
                        sh "echo $PASS | docker login myapplicationdeployments.azurecr.io -u $USER --password-stdin"
                        sh 'docker push myapplicationdeployments.azurecr.io/maven-app:6.0'
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
