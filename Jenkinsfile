pipeline {
    agent any

    environment {
        GOOGLE_APPLICATION_CREDENTIALS = credentials('gcp-service-account-json')
        DOCKER_CREDENTIALS = credentials('docker-hub-credentials')
    }

    stages {
        stage('Checkout') {
            steps {
                script {
                    def gitUrl = 'https://github.com/aazyablitsev/app-for-jenkins.git'
                    def branch = 'master'
                    def credentialsId = 'github-token'
                    retry(3) {
                        sh "git clone ${gitUrl} --branch ${branch} --single-branch --depth 1"
                    }
                }
            }
        }
        stage('Terraform Init') {
            steps {
                dir('app-for-jenkins/project') {
                    withCredentials([file(credentialsId: 'gcp-service-account-json', variable: 'GOOGLE_APPLICATION_CREDENTIALS_PATH')]) {
                        sh 'terraform init'
                    }
                }
            }
        }
        stage('Terraform Apply') {
            steps {
                dir('app-for-jenkins/project') {
                    withCredentials([file(credentialsId: 'gcp-service-account-json', variable: 'GOOGLE_APPLICATION_CREDENTIALS_PATH')]) {
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


