pipeline {
    agent any
     environment {
        KUBECONFIG = '~/.kube/config' // Specify the correct path to your Minikube kubeconfig file
    }
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


        /*stage('Scan Docker Image') {
            //steps {
                //script {
                    //echo 'Scanning Docker image...'
                    //def dockerImage = 'myapplicationdeployments.azurecr.io/maven-app:6.0'
                    //sh "trivy image --exit-code 1 --severity HIGH,CRITICAL ${dockerImage}"
                //}
            //}
        }*/

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

        stage("Install kubectl") {
            steps {
                script {
                    echo "Installing kubectl..."
                    // Download kubectl and install it in the home directory
                    sh '''
                        curl -LO "https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl"
                        chmod +x ./kubectl
                        mv ./kubectl $HOME/bin/kubectl
                    '''
                    // Add the directory to PATH
                    env.PATH = "$HOME/bin:${env.PATH}"
                }
            }
        }

        stage("Check Namespace") {
            steps {
                script {
                    echo "Checking Kubernetes namespace..."
                    sh "kubectl get namespace java-maven"
                }
            }
        }

        stage("Deploy application to kubernetes") {
            steps {
                script{
                    echo "Deploying the app..."
                    sh 'kubectl apply -f K8/deployment.yaml'
                }
                
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
