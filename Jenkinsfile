def label = "build-${UUID.randomUUID().toString()}"
def image_name = "aklearning/onse-lab-intro-to-kubernetes"
def git_commit = ''
def namespace = 'aklearning'

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
    image: aklearning/onse-eks-kubectl-deployer:0.0.1
    imagePullPolicy: Always
    tty: true

  - name: python-test
    image: python:alpine3.7
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
    git 'https://github.com/code-engine/onse-lab-intro-to-kubernetes'

    stage('Test') {
        container(name: 'python-test', shell: '/bin/sh') {
            sh 'pip install pipenv'
            sh 'pipenv install --dev'
            sh 'pipenv run python -m pytest'
        }
    }

    stage('Build with Kaniko') {
      git_commit = sh (
        script: 'git rev-parse HEAD',
        returnStdout: true
      ).trim()
      image_name += ":${git_commit}"
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
      withCredentials([
        string(credentialsId: 'AWS_ACCESS_KEY_ID', variable: 'AWS_ACCESS_KEY_ID'),
        string(credentialsId: 'AWS_SECRET_ACCESS_KEY', variable: 'AWS_SECRET_ACCESS_KEY'),
        string(credentialsId: 'KUBERNETES_SERVER', variable: 'KUBERNETES_SERVER'),
        file(credentialsId: 'KUBERNETES_CA', variable: 'KUBERNETES_CA')
      ]) {
        container(name: 'kubectl', shell: '/bin/sh',) {
          sh '''kubectl config \
              set-cluster kubernetes \
              --server=$KUBERNETES_SERVER \
              --certificate-authority=$KUBERNETES_CA
          '''
          sh "yq.v2 w -i kubernetes/deployment.yml 'spec.template.spec.containers[0].image' ${image_name}"
          sh "kubectl create namespace ${namespace} || true"
          sh "kubectl apply -n ${namespace} -f kubernetes/"
        }
      }
    }
  }
}
