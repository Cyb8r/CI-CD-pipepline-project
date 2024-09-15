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
                sh 'docker build -t myapplicationdeployments.azurecr.io/maven-app:6.0 .'
            }
        }

        stage('Push Docker Image to Azure Container Registry') {
            steps {
                sh 'docker push myapplicationdeployments.azurecr.io/maven:6.0'
                
            }
        }    
        stage("deploy") {
            steps {
                echo "deploying the app"
            }
        }

    }
}