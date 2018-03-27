#!groovy

pipeline {
    agent any

    environment {
        APPLICATION_NAME = "service_logging"
        COMPOSE_FILE = "docker-compose.jenkins.yml"
    }

    post {
        always {
            // Cleanup images after tests
            sh "docker-compose down -v --rmi=local"
        }
    }

    stages {
        stage("Prepare for tests") {
            steps {
                sh "docker-compose build"
            }
        }

        stage("Run tests") {
            post {
                always {
                    // Store Simplecov coverage report
                    archive "tmp/coverage/"
                    // Parse JUnit file to show tests information
                    junit "tmp/rspec/rspec.xml"
                }
            }

            steps {
                sh "docker-compose run --rm app bundle exec rubocop"
                sh "docker-compose run --rm app bundle exec rspec"
            }
        }
    }
}
