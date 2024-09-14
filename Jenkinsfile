pipeline {
    agent any 
    tools {
        maven 'maven-app'  
    }
    stages {
        stage("build jar") {
            steps {
                script {
                    echo "building the app....." 
                    sh 'mvn package'
                }
                
            }
        }
        stage('Build Docker Image') {
            steps {
                sh 'docker -t myapplicationdeployments.azurecr.io/maven-app myapplicationdeployments.azurecr.io/maven-app:1.0'
                
            }
        }

        stage('Push Docker Image to Azure Container Registry') {
            environment {
                ACR_URL = credentials('myapplicationdeployments.azurecr.io').getUsername()
                ACR_PASSWORD = credentials('myapplicationdeployments.azurecr.io').getPassword()
            }

            steps {
                sh 'docker login ${ACR_URL} -u ${ACR_URL} -p ${ACR_PASSWORD}'
                sh 'docker push ${ACR_URL}/maven-app:1.0'
            }
        }    
        stage("deploy") {
            steps {
                echo "deploying the app"
            }
        }

    }
}