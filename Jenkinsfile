def label = "kaniko-${UUID.randomUUID().toString()}"
def image_name = "aklearning/onse-lab-intro-to-kubernetes"
def GIT_COMMIT = ''

podTemplate(name: 'kaniko', label: label, yaml: """
kind: Pod
metadata:
  name: kaniko
spec:
  containers:
  - name: kaniko
    image: gcr.io/kaniko-project/executor:debug-539ddefcae3fd6b411a95982a830d987f4214251
    imagePullPolicy: Always
    command:
    - /busybox/cat
    tty: true
    volumeMounts:
      - name: jenkins-docker-cfg
        mountPath: /root/.docker

  - name: kubectl
    image: aklearning/onse-eks-kubectl-deployer
    imagePullPolicy: Always
    tty: true

  volumes:
  - name: jenkins-docker-cfg
    projected:
      sources:
      - secret:
          name: regcred
          items:
            - key: dockerconfigjson
              path: config.json
"""
  ) {

  node(label) {
    git 'https://github.com/ONSdigital/onse-lab-intro-to-kubernetes'
    stage('Build with Kaniko') {
        GIT_COMMIT = sh (
            script: 'git rev-parse HEAD',
            returnStdout: true
        ).trim()
        image_name += ":${GIT_COMMIT}"
        echo "Building image ${image_name}"
        container(name: 'kaniko', shell: '/busybox/sh') {
            withEnv(['PATH+EXTRA=/busybox:/kaniko']) {
                sh """#!/busybox/sh
                /kaniko/executor -f `pwd`/Dockerfile -c `pwd` --skip-tls-verify --cache=true --destination=${image_name}
                """
            }
        }
    }

    stage('kube') {
        container(name: 'kubectl', shell: '/bin/sh') {
            environment {
                AWS_ACCESS_KEY_ID     = credentials('AWS_ACCESS_KEY_ID')
                AWS_SECRET_ACCESS_KEY = credentials('AWS_SECRET_ACCESS_KEY')
            }
            sh 'kubectl config get-contexts'
        }
    }
  }
}
