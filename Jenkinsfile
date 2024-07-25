pipeline {
    agent any
    options {
        timeout(time: 1, unit: 'HOURS')
    }
    environment {
        GOOGLE_APPLICATION_CREDENTIALS = credentials('gcp-service-account')
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
        stage('Set Docker Hub Username') {
            steps {
                script {
                    withCredentials([usernamePassword(credentialsId: 'docker-hub-credentials', usernameVariable: 'DOCKER_HUB_USERNAME', passwordVariable: 'DOCKER_HUB_PASSWORD')]) {
                        env.DOCKER_HUB_USERNAME = DOCKER_HUB_USERNAME
                        env.DOCKER_HUB_PASSWORD = DOCKER_HUB_PASSWORD
                    }
                }
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
                        def app = docker.build("${env.DOCKER_HUB_USERNAME}/your-app:${env.BUILD_NUMBER}")
                        app.push()
                        app.push('latest')
                    }
                }
            }
        }
        stage('Deploy with Docker Compose') {
            steps {
                script {
                    def instanceIp = env.INSTANCE_IP
                    sshagent(['jenkins-ssh-key']) {
                        sh "scp -o StrictHostKeyChecking=no docker-compose.yml aazyablicev@${instanceIp}:/home/aazyablicev/"
                        sh "ssh -o StrictHostKeyChecking=no aazyablicev@${instanceIp} 'docker login -u ${env.DOCKER_HUB_USERNAME} -p ${env.DOCKER_HUB_PASSWORD}'"
                        sh "ssh -o StrictHostKeyChecking=no aazyablicev@${instanceIp} 'docker-compose -f /home/aazyablicev/docker-compose.yml up -d'"
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
