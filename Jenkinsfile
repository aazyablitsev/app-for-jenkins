pipeline {
    agent any

    environment {
        GOOGLE_APPLICATION_CREDENTIALS = credentials('gcp-service-account-json')
        DOCKER_CREDENTIALS = credentials('docker-hub-credentials')
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
                    withCredentials([file(credentialsId: 'gcp-service-account-json', variable: 'GOOGLE_APPLICATION_CREDENTIALS')]) {
                        sh 'terraform init'
                    }
                }
            }
        }
        stage('Terraform Apply') {
            steps {
                dir('project') {
                    withCredentials([file(credentialsId: 'gcp-service-account-json', variable: 'GOOGLE_APPLICATION_CREDENTIALS')]) {
                        sh 'terraform apply -auto-approve'
                    }
                }
            }
        }
        stage('Build Docker Image') {
            steps {
                script {
                    docker.withRegistry('https://index.docker.io/v1/', 'DOCKER_CREDENTIALS') {
                        docker.build('your-app').push('latest')
                    }
                }
            }
        }
        stage('Deploy with Docker Compose') {
            steps {
                script {
                    def instanceIp = '34.89.101.117'
                    sh 'scp -i /path/to/key docker-compose.yml your-user@' + instanceIp + ':/path/to/deploy'
                    sh 'ssh -i /path/to/key your-user@' + instanceIp + ' "docker-compose -f /path/to/deploy/docker-compose.yml up -d"'
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

