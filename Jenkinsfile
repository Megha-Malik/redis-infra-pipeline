pipeline {
    agent any

    environment {
        AWS_DEFAULT_REGION = 'ap-south-1'
        TF_DIR             = 'terraform'
        ANSIBLE_DIR        = 'ansible'
        AWS_KEY_NAME       = 'Redis-key' // <--- Apna AWS SSH Key ka naam yahan likhein
    }

    stages {
        stage('Checkout Source Code') {
            steps {
                checkout scm
            }
        }

        stage('Terraform Provisioning') {
    steps {
        withCredentials([[
            $class: 'AmazonWebServicesCredentialsBinding',
            credentialsId: 'aws-credentials',
            accessKeyVariable: 'AWS_ACCESS_KEY_ID',
            secretKeyVariable: 'AWS_SECRET_ACCESS_KEY'
        ]]) {
            dir(env.TF_DIR) {
                sh 'terraform init'
                sh "terraform apply -auto-approve -var=\"key_name=${env.AWS_KEY_NAME}\""
            }
        }
    }
}

        stage('Wait For Server Boot') {
            steps {
                echo 'Waiting 30 seconds for instances to complete SSH initialization...'
                sleep time: 30, unit: 'SECONDS'
            }
        }

        stage('Ansible Configuration') {
            steps {
                withCredentials([
                    usernamePassword(credentialsId: 'aws-credentials', usernameVariable: 'AWS_ACCESS_KEY_ID', passwordVariable: 'AWS_SECRET_ACCESS_KEY'),
                    file(credentialsId: 'ssh-private-key', variable: 'SSH_KEY')
                ]) {
                    dir(env.ANSIBLE_DIR) {
                        sh 'cp $SSH_KEY /tmp/id_rsa && chmod 600 /tmp/id_rsa'
                        sh 'ansible-inventory -i aws_ec2.yml --graph'
                        
                        sh '''
                          ansible-playbook -i aws_ec2.yml playbook.yml -u ubuntu --extra-vars "ansible_ssh_common_args='-o StrictHostKeyChecking=no'" || \
                          ansible-playbook -i aws_ec2.yml playbook.yml -u ec2-user --extra-vars "ansible_ssh_common_args='-o StrictHostKeyChecking=no'"
                        '''
                    }
                }
            }
        }
    }

    post {
        always {
            sh 'rm -f /tmp/id_rsa'
        }
    }
}