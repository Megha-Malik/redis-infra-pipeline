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
        // SSH Key Credential use karein (jaise 'ssh-key-id' jo 'SSH Username with private key' type ka ho)
        withCredentials([sshUserPrivateKey(credentialsId: 'ssh-private-key', keyFileVariable: 'SSH_KEY')]) {
            dir('ansible') {
                sh '''
                    chmod 400 $SSH_KEY
                    ansible-playbook -i inventory.ini playbook.yml --private-key $SSH_KEY
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