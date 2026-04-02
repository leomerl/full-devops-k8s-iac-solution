def appname = "hello-newapp"
def repo = "rougawh"
def appimage = "${repo}/${appname}"
def apptag = "${env.BUILD_NUMBER}"
def gitrepo = "git@github.com:leomerl/full-devops-k8s-iac-solution.git"
def kustomizeVersion = "v5.4.3"

podTemplate(
  containers: [
    containerTemplate(name: 'kaniko', image: 'gcr.io/kaniko-project/executor:v1.23.0-debug', command: '/busybox/cat', ttyEnabled: true)
  ],
  volumes: [
    secretVolume(secretName: 'dockerhub-creds', mountPath: '/kaniko/.docker'),
    secretVolume(secretName: 'jenkins-git-ssh', mountPath: '/root/.ssh')
  ]
) {
  node(POD_LABEL) {
    stage('checkout') {
      checkout scm
    }

    stage('build & push') {
      container('kaniko') {
        sh "/kaniko/executor --context=${env.WORKSPACE} --dockerfile=${env.WORKSPACE}/Dockerfile --destination=${appimage}:${apptag} --destination=${appimage}:latest"
      }
    }

    stage('gitops') {
      sh """
        curl -sL "https://github.com/kubernetes-sigs/kustomize/releases/download/kustomize%2F${kustomizeVersion}/kustomize_${kustomizeVersion}_linux_amd64.tar.gz" | tar xz -C /usr/local/bin
      """

      sh """
        chmod 600 /root/.ssh/id_rsa
        ssh-keyscan github.com >> /root/.ssh/known_hosts
        git clone --branch gitops --single-branch ${gitrepo} gitops-repo
      """

      sh """
        mkdir -p gitops-repo/manifests/${appname}
        cp -r ${env.WORKSPACE}/k8s/. gitops-repo/manifests/${appname}/
      """

      sh "cd gitops-repo/manifests/${appname} && kustomize edit set image ${appimage}:${apptag}"

      sh """
        cd gitops-repo
        git config user.email "jenkins@ci"
        git config user.name "Jenkins"
        git add manifests/${appname}/
        git diff --cached --quiet || git commit -m "Update ${appname} image to build ${apptag}"
        git push origin gitops
      """
    }
  }
}
