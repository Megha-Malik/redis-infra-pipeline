pipeline {
    agent any

    environment {
        AWS_DEFAULT_REGION = 'ap-south-1'
        TF_DIR             = 'terraform'
        ANSIBLE_DIR        = 'ansible'
        AWS_KEY_NAME       = 'Redis-key'
        BASTION_USER       = 'ec2-user' // Amazon Linux Bastion User
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
                        
                        // Terraform Outputs se Bastion Public IP dynamically fetch kar rahe hain
                        script {
                            env.BASTION_IP = sh(
                                script: 'terraform output -raw bastion_public_ip',
                                returnStdout: true
                            ).trim()
                        }
                    }
                }
            }
        }

        stage('Wait For Server Boot') {
            steps {
                echo "Bastion IP: ${env.BASTION_IP}"
                echo 'Waiting 30 seconds for instances to complete SSH initialization...'
                sleep time: 30, unit: 'SECONDS'
            }
        }

        stage('Ansible Configuration') {
    steps {
        withCredentials([
            sshUserPrivateKey(credentialsId: 'ssh-key-id', keyFileVariable: 'SSH_KEY'),
            amazonWebServices(credentialsId: 'aws-credentials-id', accessKeyVariable: 'AWS_ACCESS_KEY_ID', secretKeyVariable: 'AWS_SECRET_ACCESS_KEY')
        ]) {
            dir('ansible') {
                sh '''
                    export AWS_REGION="ap-south-1"
                    ansible-playbook -i aws_ec2.yml playbook.yml --private-key $SSH_KEY
                '''
            }
        }
    }
}

    post {
        always {
            cleanWs() // Pipeline completion par workspace artifacts safely clear karne ke liye
        }
        success {
            echo "One-Click Deployment Successful! Redis configured on Private Instances via Bastion Host."
        }
        failure {
            echo "Deployment Failed! Check the step logs above for details."
        }
    }
}