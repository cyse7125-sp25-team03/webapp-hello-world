node {
    def NEW_VERSION

    stage('Clone repository') {
        checkout scm
    }

    stage('Calculate Version') {
        script {
            // Create version calculation script
            writeFile file: 'calculate_version.sh', text: '''
            #!/bin/bash
            calculate_version() {
                LATEST_TAG=$(git describe --tags --abbrev=0 2>/dev/null || echo "v0.0.0")
                
                MAJOR=$(echo $LATEST_TAG | cut -d. -f1 | tr -d 'v')
                MINOR=$(echo $LATEST_TAG | cut -d. -f2)
                PATCH=$(echo $LATEST_TAG | cut -d. -f3)
                
                COMMIT_MSG=$(git log -1 --pretty=%B)
                
                if echo "$COMMIT_MSG" | grep -qE "^[a-z]+\\([a-z]+\\)!:" || echo "$COMMIT_MSG" | grep -q "BREAKING CHANGE"; then
                    MAJOR=$((MAJOR + 1))
                    MINOR=0
                    PATCH=0
                elif echo "$COMMIT_MSG" | grep -qE "^feat\\([a-z]+\\):"; then
                    MINOR=$((MINOR + 1))
                    PATCH=0
                else
                    PATCH=$((PATCH + 1))
                fi
                
                echo "v$MAJOR.$MINOR.$PATCH"
            }

            NEW_VERSION=$(calculate_version)
            echo $NEW_VERSION
            '''
            // Make script executable and run it
            sh 'chmod +x calculate_version.sh'
            NEW_VERSION = sh(returnStdout: true, script: './calculate_version.sh').trim()
            echo "Building version: ${NEW_VERSION}"
        }
    }

    stage('Build and Push multi-platform image') {
        withCredentials([usernamePassword(credentialsId: 'docker-pat', usernameVariable: 'DOCKER_USERNAME', passwordVariable: 'DOCKER_TOKEN')]) {
            sh """
                docker login -u ${DOCKER_USERNAME} -p ${DOCKER_TOKEN}
                docker buildx create --use --name builder || docker buildx use builder
                docker buildx inspect --bootstrap

                # Build and push the multi-platform image
                docker buildx build \\
                    --platform linux/amd64,linux/arm64 \\
                    -t roarceus/webapp-hello-world:${NEW_VERSION} \\
                    -t roarceus/webapp-hello-world:latest \\
                    --push .
            """
        }
    }

    stage('Tag Repository') {
        withCredentials([usernamePassword(credentialsId: 'github-pat', usernameVariable: 'GITHUB_USERNAME', passwordVariable: 'GITHUB_TOKEN')]) {
            sh """
                git config user.email "jenkins@csyeteam03.xyz"
                git config user.name "Automated Release Bot"
                git tag -a ${NEW_VERSION} -m "Release ${NEW_VERSION}"
                git push https://${GITHUB_USERNAME}:${GITHUB_TOKEN}@github.com/cyse7125-sp25-team03/webapp-hello-world.git ${NEW_VERSION}
            """
        }
    }
}