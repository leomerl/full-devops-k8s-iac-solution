pipelineJob('app-pipeline') {
  definition {
    cpsScm {
      scm {
        git {
          remote {
            url('https://github.com/leomerl/full-devops-k8s-iac-solution.git')
          }
          branch('app')
        }
      }
      scriptPath('Jenkinsfile')
    }
  }
}
