pipeline {
    agent any
    
    environment {
        // The JFrog server ID
        JFROG_SERVER = 'trialjdz9wr' 
        JF_URL = "https://${JFROG_SERVER}.jfrog.io"
        JF_PROJECT = 'petclinic' // Our explicit project key
        
        DOCKER_REGISTRY = "${JFROG_SERVER}.jfrog.io"
        MAVEN_REPO = 'petclinic-maven'
        DOCKER_REPO = 'petclinic-docker'
        
        IMAGE_NAME = "${DOCKER_REGISTRY}/${DOCKER_REPO}/spring-petclinic:${env.BUILD_NUMBER}"
        BUILD_NAME = 'petclinic-pipeline'
    }

    stages {
        stage('Compile & Test') {
            steps {
                withCredentials([string(credentialsId: 'jfrog-access-token', variable: 'JF_ACCESS_TOKEN')]) {
                    
                    // 1. Clean state
                    sh "jf config remove ${JFROG_SERVER} --quiet || true"
                    
                    // 2. Configure CLI
                    sh "jf config add ${JFROG_SERVER} --url=${JF_URL} --access-token=\$JF_ACCESS_TOKEN --interactive=false"
                    
                    // 3. Configure Maven
                    sh "jf mvnc --server-id-resolve=${JFROG_SERVER} --server-id-deploy=${JFROG_SERVER} --repo-resolve-releases=${MAVEN_REPO} --repo-resolve-snapshots=${MAVEN_REPO} --repo-deploy-releases=petclinic-maven-local --repo-deploy-snapshots=petclinic-maven-local"
                    
                    // 4. Compile with explicit --project flag
                    sh "jf mvn clean install -U --build-name=${BUILD_NAME} --build-number=${BUILD_NUMBER} --project=${JF_PROJECT}"
                }
            }
        }

        stage('Docker Build') {
            steps {
                sh "docker build -t ${IMAGE_NAME} ."
            }
        }

        stage('Docker Push & Traceability') {
            steps {
                withCredentials([string(credentialsId: 'jfrog-access-token', variable: 'JF_ACCESS_TOKEN')]) {
                    // Push and collect info with explicit --project flags
                    sh "jf docker push ${IMAGE_NAME} --build-name=${BUILD_NAME} --build-number=${BUILD_NUMBER} --project=${JF_PROJECT}"
                    sh "jf rt bce ${BUILD_NAME} ${BUILD_NUMBER} --project=${JF_PROJECT}"
                    sh "jf rt bp ${BUILD_NAME} ${BUILD_NUMBER} --project=${JF_PROJECT}"
                }
            }
        }

        stage('Xray Scan & Quality Gate') {
            steps {
                withCredentials([string(credentialsId: 'jfrog-access-token', variable: 'JF_ACCESS_TOKEN')]) {
                    // Scan the build within the specific project
                    sh "jf bs ${BUILD_NAME} ${BUILD_NUMBER} --project=${JF_PROJECT} --fail=true"
                }
            }
        }
    }
}