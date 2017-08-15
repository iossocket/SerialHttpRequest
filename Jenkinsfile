node {
    stage('Checkout') {
       checkout scm
    }

    stage('Test') {
        sh "fastlane test"
    }
}
