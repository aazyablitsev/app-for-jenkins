pipeline {
    agent any
    options {
        timeout(time: 1, unit: 'HOURS')
    }
    environment {
        GOOGLE_APPLICATION_CREDENTIALS = credentials('gcp-service-account')
        DOCKER_HUB_CREDENTIALS = credentials('docker-hub-credentials')
    }
    stages {
        stage('Prepare Workspace') {
            steps {
                cleanWs()
            }
        }
        stage('Checkout') {
            steps {
                retry(3) {
                    timeout(time: 5, unit: 'MINUTES') {
                        checkout([$class: 'GitSCM', 
                            branches: [[name: '*/master']], 
                            userRemoteConfigs: [[
                                url: 'https://github.com/aazyablitsev/app-for-jenkins.git', 
                                credentialsId: 'github-token'
                            ]]
                        ])
                    }
                }
            }
        }
        stage('Set Docker Hub Credentials') {
            steps {
                script {
                    env.DOCKER_HUB_USERNAME = DOCKER_HUB_CREDENTIALS_USR
                    env.DOCKER_HUB_PASSWORD = DOCKER_HUB_CREDENTIALS_PSW
                }
            }
        }
        stage('Add SSH Host to Known Hosts') {
            steps {
                script {
                    sh "ssh-keyscan -H 34.105.216.233 >> ~/.ssh/known_hosts"
                }
            }
        }
        stage('Terraform Init and Apply') {
            steps {
                dir('project') {
                    sh 'terraform init'
                    sh 'terraform apply -auto-approve'
                    script {
                        env.INSTANCE_IP = sh(script: 'terraform output -raw instance_ip', returnStdout: true).trim()
                    }
                }
            }
        }
        stage('Build and Push Docker Image') {
            steps {
                script {
                    docker.withRegistry('https://index.docker.io/v1/', 'docker-hub-credentials') {
                        def app = docker.build("${DOCKER_HUB_USERNAME}/nginx-app:${env.BUILD_NUMBER}", './website')
                        app.push()
                        app.push('latest')
                    }
                }
            }
        }
        stage('Deploy with Docker Compose') {
            steps {
                script {
                    sshagent(['jenkins-ssh-key']) {
                        sh "ssh -o StrictHostKeyChecking=no aazyablicev@${INSTANCE_IP} 'docker-compose down'"
                        sh "scp -o StrictHostKeyChecking=no docker-compose.yml aazyablicev@${INSTANCE_IP}:/home/aazyablicev/"
                        sh "scp -o StrictHostKeyChecking=no website/nginx.conf aazyablicev@${INSTANCE_IP}:/home/aazyablicev/website/"
                        sh "ssh -o StrictHostKeyChecking=no aazyablicev@${INSTANCE_IP} 'docker-compose up -d'"
                    }
                }
            }
        }
    }
    post {
        always {
            cleanWs()
        }
    }
}



