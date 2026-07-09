pipeline {
  agent any
 
  parameters {
    choice(name: 'ENVIRONMENT', choices: ['dev', 'staging', 'prod'], description: 'Target environment')
    booleanParam(name: 'AUTO_APPROVE', defaultValue: false, description: 'Skip manual approval (dev/staging only)')
  }
 
  environment {
    AWS_DEFAULT_REGION = 'us-east-1'
    TF_IN_AUTOMATION    = 'true'
    TF_VAR_db_password   = credentials('cloudcart-db-password')
  }
 
  options {
    timestamps()
    disableConcurrentBuilds()
    ansiColor('xterm')
  }
 
  stages {
 
    stage('Checkout') {
      steps {
        checkout scm
      }
    }
 
    stage('Terraform Format Check') {
      steps {
        dir("environments/${params.ENVIRONMENT}") {
          sh 'terraform fmt -check -recursive'
        }
      }
    }
 
    stage('Terraform Init') {
      steps {
        dir("environments/${params.ENVIRONMENT}") {
          withAWS(credentials: 'aws-cloudcart-pipeline', region: env.AWS_DEFAULT_REGION) {
            sh 'terraform init -input=false'
          }
        }
      }
    }
 
    stage('Terraform Validate') {
      steps {
        dir("environments/${params.ENVIRONMENT}") {
          sh 'terraform validate'
        }
      }
    }
 
    stage('Security Scan (tfsec)') {
      steps {
        dir("environments/${params.ENVIRONMENT}") {
          sh 'tfsec . --minimum-severity HIGH --soft-fail'
        }
      }
    }
 
    stage('Terraform Plan') {
      steps {
        dir("environments/${params.ENVIRONMENT}") {
          withAWS(credentials: 'aws-cloudcart-pipeline', region: env.AWS_DEFAULT_REGION) {
            sh 'terraform plan -input=false -out=tfplan'
            sh 'terraform show -no-color tfplan > tfplan.txt'
          }
        }
        archiveArtifacts artifacts: "environments/${params.ENVIRONMENT}/tfplan.txt"
      }
    }
 
    stage('Manual Approval') {
      when {
        expression { params.ENVIRONMENT == 'prod' && !params.AUTO_APPROVE }
      }
      steps {
        script {
          def planOutput = readFile("environments/${params.ENVIRONMENT}/tfplan.txt")
          input message: "Review the Terraform plan for PROD. Apply changes?",
                ok: 'Apply',
                submitter: 'cloudcart-infra-leads'
        }
      }
    }
 
    stage('Terraform Apply') {
      steps {
        dir("environments/${params.ENVIRONMENT}") {
          withAWS(credentials: 'aws-cloudcart-pipeline', region: env.AWS_DEFAULT_REGION) {
            sh 'terraform apply -input=false tfplan'
          }
        }
      }
    }
  }
 
  post {
    success {
      slackSend(channel: '#cloudcart-infra', color: 'good',
        message: "✅ ${params.ENVIRONMENT} infrastructure updated successfully - build ${env.BUILD_NUMBER}")
    }
    failure {
      slackSend(channel: '#cloudcart-infra', color: 'danger',
        message: "❌ Pipeline failed for ${params.ENVIRONMENT} - build ${env.BUILD_NUMBER} - ${env.BUILD_URL}")
    }
    always {
      cleanWs()
    }
  }
}
