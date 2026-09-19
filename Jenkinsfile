pipeline {
    agent any
    
    tools {
        maven 'Maven 3'
        jdk 'Java 17'
    }
    
    environment {
        DOCKER_HUB_CREDENTIALS = credentials('docker-hub-creds')
        IMAGE_NAME = "aniketaragkar/petclinic-app"
        IMAGE_TAG = "${env.BUILD_NUMBER}"
    }
    
    stages {
        stage('Checkout Code') {
            steps {
                checkout scm
            }
        }
        
        stage('Unit Tests') {
            steps {
                echo 'Running JUnit Tests...'
                sh './mvnw clean test -Dtest=!PetClinicConcurrencyTests'
            }
            post {
                always {
                    junit 'target/surefire-reports/*.xml'
                }
            }
        }
        
        stage('SonarQube Analysis') {
            environment {
                SCANNER_HOME = tool 'SonarQubeScanner'
            }
            steps {
                withSonarQubeEnv('SonarQube') {
                    sh '''
                    ./mvnw org.sonarsource.scanner.maven:sonar-maven-plugin:sonar \
                      -Dsonar.projectKey=petclinic \
                      -Dsonar.projectName=petclinic \
                      -Dsonar.java.binaries=target/classes
                    '''
                }
            }
        }
        
        stage('Build Docker Image') {
            steps {
                echo 'Building Docker Image...'
                sh 'docker build -t ${IMAGE_NAME}:${IMAGE_TAG} .'
                sh 'docker tag ${IMAGE_NAME}:${IMAGE_TAG} ${IMAGE_NAME}:latest'
            }
        }
        
        stage('Push to Docker Hub') {
            steps {
                echo 'Pushing to Docker Registry...'
                sh 'echo $DOCKER_HUB_CREDENTIALS_PSW | docker login -u $DOCKER_HUB_CREDENTIALS_USR --password-stdin'
                sh 'docker push ${IMAGE_NAME}:${IMAGE_TAG}'
                sh 'docker push ${IMAGE_NAME}:latest'
            }
        }

        stage('Deploy to Kubernetes') {
            steps {
                echo 'Deploying application to K3s cluster...'
                withCredentials([file(credentialsId: 'k8s-kubeconfig', variable: 'KUBECONFIG')]) {
                    sh '''
                    # Download kubectl directly to the workspace to avoid sudo permissions
                    if [ ! -f "./kubectl" ]; then
                        curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
                        chmod +x ./kubectl
                    fi
                
                    # Apply the Kubernetes manifests using the local binary
                    ./kubectl --kubeconfig=$KUBECONFIG apply -f k8s-deploy.yaml
                    '''
                }
            }
        }
    }
}