pipeline {
    agent any

    environment {
        AWS_REGION = 'ap-south-1' // Apne AWS region ke hisaab se update karein
    }

    stages {
        stage('Checkout Source Code') {
            steps {
                checkout scm
            }
        }

        stage('Terraform Provisioning') {
            steps {
                withCredentials([
                    aws(
                        credentialsId: 'aws-credentials', // Updated to match your Jenkins credential ID
                        accessKeyVariable: 'AWS_ACCESS_KEY_ID',
                        secretKeyVariable: 'AWS_SECRET_ACCESS_KEY'
                    )
                ]) {
                    dir('terraform') {
                        sh 'terraform init'
                        sh 'terraform apply -auto-approve -var=key_name=Redis-key'
                    }
                }
            }
        }

        stage('Wait For Server Boot') {
            steps {
                echo 'Waiting 30 seconds for EC2 instances to finish boot and SSH initialization...'
                sleep 30
            }
        }

        stage('Ansible Configuration') {
            steps {
                withCredentials([
                    sshUserPrivateKey(credentialsId: 'redis-key-id', keyFileVariable: 'SSH_KEY'),
                    aws(
                        credentialsId: 'aws-credentials', // Updated to match your Jenkins credential ID
                        accessKeyVariable: 'AWS_ACCESS_KEY_ID',
                        secretKeyVariable: 'AWS_SECRET_ACCESS_KEY'
                    )
                ]) {
                    dir('ansible') {
                        sh '''
                            chmod 400 $SSH_KEY
                            export ANSIBLE_HOST_KEY_CHECKING=False
                            export AWS_REGION=$AWS_REGION
                            ansible-galaxy collection install amazon.aws --force
                            ansible-playbook -i aws_ec2.yml playbook.yml \
                              --private-key $SSH_KEY \
                              --ssh-common-args='-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null'
                        '''
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