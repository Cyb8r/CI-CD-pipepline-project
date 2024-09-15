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
                script{
                    withCredentials([usernamePassword(credentialsId:'myapplicationmyapplicationdeployments.azurecr.io', passwordVariable: 'PASS', usernameVariable:'USER'])){
                        sh "echo $PASS | docker login -u $USER --password-stdin"
                        sh 'docker push myapplicationdeployments.azurecr.io/maven-app:6.0'
                    }
                    
                }
            }
        }    
        stage("deploy") {
            steps {
                echo "deploying the app"
            }
        }

    }
}