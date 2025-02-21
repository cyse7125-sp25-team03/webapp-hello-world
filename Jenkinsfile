node {
    def NEW_VERSION

    stage('Clone repository') {
        withCredentials([usernamePassword(credentialsId: 'github-pat', usernameVariable: 'GITHUB_USERNAME', passwordVariable: 'GITHUB_TOKEN')]) {
        checkout([$class: 'GitSCM',
                branches: [[name: '*/main']],
                extensions: [[$class: 'CloneOption',
                            noTags: false,
                            shallow: false,
                            depth: 0,
                            reference: '']],
                userRemoteConfigs: [[
                    url: "https://${GITHUB_TOKEN}@github.com/cyse7125-sp25-team03/webapp-hello-world.git",
                    credentialsId: 'github-pat'
                ]]])
        }
    }

    stage('Calculate Version') {
        script {
            // Create version calculation script
            writeFile file: 'calculate_version.sh', text: '''#!/bin/bash
            calculate_version() {
                # Fetch all tags first
                git fetch --tags
                
                # Get latest tag or default to v0.0.0 if none exists
                LATEST_TAG=$(git describe --tags --abbrev=0 2>/dev/null || echo "v0.0.0")
                
                echo "Latest tag found: $LATEST_TAG"
                
                MAJOR=$(echo $LATEST_TAG | cut -d. -f1 | tr -d 'v')
                MINOR=$(echo $LATEST_TAG | cut -d. -f2)
                PATCH=$(echo $LATEST_TAG | cut -d. -f3)
                
                COMMIT_MSG=$(git log -1 --pretty=%B)
                
                # Determine version bump type based on commit message
                if echo "$COMMIT_MSG" | grep -qE "^[a-z]+\\([a-z]+\\)!:" || echo "$COMMIT_MSG" | grep -q "BREAKING CHANGE"; then
                    VERSION_TYPE="MAJOR"
                    MAJOR=$((MAJOR + 1))
                    MINOR=0
                    PATCH=0
                elif echo "$COMMIT_MSG" | grep -qE "^feat\\([a-z]+\\):"; then
                    VERSION_TYPE="MINOR"
                    MINOR=$((MINOR + 1))
                    PATCH=0
                else
                    VERSION_TYPE="PATCH"
                    PATCH=$((PATCH + 1))
                fi
                
                NEW_VERSION="v$MAJOR.$MINOR.$PATCH"
                echo "Initial calculated version: $NEW_VERSION ($VERSION_TYPE change)"
                
                # Check if tag already exists and handle according to semantic versioning
                while git rev-parse "$NEW_VERSION" >/dev/null 2>&1 || git ls-remote --tags origin | grep -q "refs/tags/${NEW_VERSION}"; do
                    echo "Warning: Tag $NEW_VERSION already exists, incrementing according to change type"
                    
                    if [ "$VERSION_TYPE" = "MAJOR" ]; then
                        MAJOR=$((MAJOR + 1))
                        MINOR=0
                        PATCH=0
                    elif [ "$VERSION_TYPE" = "MINOR" ]; then
                        MINOR=$((MINOR + 1))
                        PATCH=0
                    else
                        PATCH=$((PATCH + 1))
                    fi
                    
                    NEW_VERSION="v$MAJOR.$MINOR.$PATCH"
                    echo "Trying new version: $NEW_VERSION"
                done
                
                echo "$NEW_VERSION"
            }

            calculate_version
            '''
            // Make script executable and run it with bash explicitly
            sh 'chmod 755 calculate_version.sh'
            NEW_VERSION = sh(returnStdout: true, script: '/bin/bash calculate_version.sh').trim()
            echo "Building version: ${NEW_VERSION}"
        }
    }

    stage('Build and Push multi-platform image') {
        withCredentials([usernamePassword(credentialsId: 'docker-pat', usernameVariable: 'DOCKER_USERNAME', passwordVariable: 'DOCKER_TOKEN')]) {
            // Login to Docker
            sh """
                docker login -u ${DOCKER_USERNAME} -p ${DOCKER_TOKEN}
            """
            
            // Setup buildx
            sh """
                docker buildx create --use --name builder || docker buildx use builder
                docker buildx inspect --bootstrap
            """
            
            // Build and push multi-platform image
            sh """
                docker buildx build \
                    --platform linux/amd64,linux/arm64 \
                    -t roarceus/webapp-hello-world:${NEW_VERSION} \
                    -t roarceus/webapp-hello-world:latest \
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