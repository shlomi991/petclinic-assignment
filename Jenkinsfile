pipeline {
    agent any
    
    environment {
        // Replace '<YOUR-SERVER-NAME>' with your actual JFrog Trial server name (e.g., 'shlomi')
        JFROG_SERVER = 'trialjdz9wr' 
        JF_URL = "https://${JFROG_SERVER}.jfrog.io"
        
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
                    // 1. Remove existing config (if any) to prevent "already exists" errors on subsequent runs
                    sh "jf config remove ${JFROG_SERVER} --quiet || true"
                    
                    // 2. Configure the JFrog CLI explicitly with our server details
                    sh "jf config add ${JFROG_SERVER} --url=${JF_URL} --access-token=\$JF_ACCESS_TOKEN --interactive=false"
                    
                    // 3. Configure Maven to resolve and deploy using our specific server and repositories
                    sh "jf mvnc --server-id-resolve=${JFROG_SERVER} --server-id-deploy=${JFROG_SERVER} --repo-resolve-releases=${MAVEN_REPO} --repo-resolve-snapshots=${MAVEN_REPO} --repo-deploy-releases=petclinic-maven-local --repo-deploy-snapshots=petclinic-maven-local"
                    
                    // 4. Compile the code and run tests using JFrog CLI
                    sh "jf mvn clean install -U --build-name=${BUILD_NAME} --build-number=${BUILD_NUMBER}"
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
                    // Push the image and record the build info
                    sh "jf docker push ${IMAGE_NAME} --build-name=${BUILD_NAME} --build-number=${BUILD_NUMBER}"
                    sh "jf rt bce ${BUILD_NAME} ${BUILD_NUMBER}"
                    sh "jf rt bp ${BUILD_NAME} ${BUILD_NUMBER}"
                }
            }
        }

        stage('Xray Scan & Quality Gate') {
            steps {
                withCredentials([string(credentialsId: 'jfrog-access-token', variable: 'JF_ACCESS_TOKEN')]) {
                    // Scan the build for severe vulnerabilities
                    sh "jf bs ${BUILD_NAME} ${BUILD_NUMBER} --fail=true"
                }
            }
        }
    }
}