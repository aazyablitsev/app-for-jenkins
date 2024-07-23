pipeline {
    agent any

    environment {
        GOOGLE_APPLICATION_CREDENTIALS = credentials('gcp-service-account')
        DOCKER_CREDENTIALS = credentials('docker-hub-credentials')
    }

    stages {
        stage('Checkout') {
            steps {
                git url: 'git@github.com:aazyablitsev/app-for-jenkins.git', branch: 'master', credentialsId: 'github-ssh-key'
            }
        }
        stage('Terraform Init') {
            steps {
                sh 'terraform init'
            }
        }
        stage('Terraform Apply') {
            steps {
                sh 'terraform apply -auto-approve'
            }
        }
        stage('Build Docker Image') {
            steps {
                script {
                    docker.withRegistry('https://index.docker.io/v1/', 'docker-hub-credentials') {
                        docker.build('your-app').push('latest')
                    }
                }
            }
        }
        stage('Deploy with Docker Compose') {
            steps {
                sh 'scp -i /path/to/key docker-compose.yml your-user@${instance_ip}:/path/to/deploy'
                sh 'ssh -i /path/to/key your-user@${instance_ip} "docker-compose -f /path/to/deploy/docker-compose.yml up -d"'
            }
        }
    }

    post {
        always {
            cleanWs()
        }
    }
}
