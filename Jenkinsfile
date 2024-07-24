pipeline {
    agent any
    environment {
        GOOGLE_APPLICATION_CREDENTIALS = credentials('gcp-service-account')
        DOCKER_HUB_USERNAME = credentials('docker-hub-credentials').username
    }
    stages {
        stage('Checkout') {
            steps {
                git url: 'https://github.com/aazyablitsev/app-for-jenkins.git', branch: 'master', credentialsId: 'github-token'
            }
        }
        stage('Terraform Init') {
            steps {
                dir('project') {
                    sh 'terraform init'
                }
            }
        }
        stage('Terraform Apply') {
            steps {
                dir('project') {
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
                        def app = docker.build("${DOCKER_HUB_USERNAME}/your-app:${env.BUILD_NUMBER}")
                        app.push()
                        app.push('latest')
                    }
                }
            }
        }
        stage('Deploy with Docker Compose') {
            steps {
                sshagent(['jenkins-ssh-key']) {
                    sh "scp docker-compose.yml ubuntu@${env.INSTANCE_IP}:/home/ubuntu/"
                    sh "ssh ubuntu@${env.INSTANCE_IP} 'docker-compose -f /home/ubuntu/docker-compose.yml up -d'"
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
