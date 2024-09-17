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
                    def dockerImage = 'myapplicationdeployments.azurecr.io/maven-app:6.0'
                    sh "docker build -t ${dockerImage} ."
                }
            }
        }

        stage('Install Trivy') {
            steps {
                script {
                    echo "Installing Trivy..."
                    // Install Trivy in the current directory
                    sh 'curl -sfL https://raw.githubusercontent.com/aquasecurity/trivy/main/contrib/install.sh | sh -s -- -b $HOME/bin'
                    // Add the new location to the PATH for this session
                    env.PATH = "${env.HOME}/bin:${env.PATH}"
                }
            }
        }


        stage('Scan Docker Image') {
            steps {
                script {
                    echo 'Scanning Docker image...'
                    def dockerImage = 'myapplicationdeployments.azurecr.io/maven-app:6.0'
                    sh "trivy image --exit-code 1 --severity high,critical ${dockerImage}"
                }
            }
        }

        stage('Push Docker Image to Azure Container Registry') {
            steps {
                script {
                    echo "Pushing Docker image to ACR..."
                    withCredentials([usernamePassword(credentialsId: 'azure-cr-credentials', passwordVariable: 'PASSWORD', usernameVariable: 'USERNAME')]) {
                        def dockerImage = 'myapplicationdeployments.azurecr.io/maven-app:6.0'
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
