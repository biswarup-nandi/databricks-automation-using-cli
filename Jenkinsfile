pipeline {
    agent any
    
    stages {
        stage('Pull Code') {
            steps {
                git credentialsId: 'bn-cred', url: 'https://github.com/your/repository.git'
            }
        }
        
        stage('Check jq') {
            steps {
                sh 'jq --version || echo "jq not found"'
            }
        }
        
        stage('Check Databricks CLI') {
            steps {
                sh 'databricks --version || echo "Databricks CLI not found"'
            }
        }
        
        stage('Run Script') {
            steps {
                sh './main.sh'
            }
        }
    }
    
    post {
        always {
            catchError {
                // Check for any errors
                echo 'Checking for errors...'
                sh 'if [ -n "$(find . -name "*.log")" ]; then cat *.log; fi'
            }
        }
    }
}

