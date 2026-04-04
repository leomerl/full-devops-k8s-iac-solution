## 01 Create tfstate bucket
* Bootstrap folder will create a shared bucket for your tfstate files 
* Run `terraform plan` and `terraform apply` from folder 01-bootstrap  


## 02 Create K3S
* Create ec2 machine with k3s single node cluster (minimal k8ss version)
* Run `export KUBECONFIG=k3s.yaml` to access your new cluster


## 03 Configure cluster
* Add docker.com token: `Account Settings` -> `Personal access tokens`
* Add github.com token: `Security` -> `personal access tokens` -> `Fine-grained tokens`

### Login to Argo
`kubectl port-forward -n argocd svc/argo-cd-argocd-server  8443:443`

[ArgoCD on https://localhost:8443/applications ](https://localhost:8443/applications) admin:Aa123456