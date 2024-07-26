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
        stage('Clean Terraform State') {
            steps {
                sh 'rm -rf $WORKSPACE/.terraform $WORKSPACE/terraform.tfstate $WORKSPACE/terraform.tfstate.backup'
                sh 'gsutil rm -r gs://my-terraform-bucket/terraform/state || true'
            }
        }
        stage('Prepare Workspace') {
            steps {
                cleanWs()
            }
        }
        stage('Checkout') {
            steps {
                retry(3) {
                    timeout(time: 5, unit: 'MINUTES') {
                        script {
                            sh 'mkdir -p ~/.ssh'
                            sh 'ssh-keyscan github.com >> ~/.ssh/known_hosts'
                        }
                        sshagent(['github-ssh-key']) {
                            checkout([$class: 'GitSCM', 
                                branches: [[name: '*/master']], 
                                userRemoteConfigs: [[
                                    url: 'git@github.com:aazyablitsev/app-for-jenkins.git', 
                                    credentialsId: 'github-ssh-key'
                                ]]
                            ])
                        }
                    }
                }
            }
        }
        stage('Set Docker Hub Username') {
            steps {
                script {
                    env.DOCKER_HUB_USERNAME = DOCKER_HUB_CREDENTIALS_USR
                    env.DOCKER_HUB_PASSWORD = DOCKER_HUB_CREDENTIALS_PSW
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
                        def app = docker.build("${DOCKER_HUB_USERNAME}/nginx-app:${env.BUILD_NUMBER}")
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
                        sh "scp -o StrictHostKeyChecking=no docker-compose.yml aazyablicev@${INSTANCE_IP}:/home/aazyablicev/"
                        sh "ssh -o StrictHostKeyChecking=no aazyablicev@${INSTANCE_IP} 'docker-compose -f /home/aazyablicev/docker-compose.yml up -d'"
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
