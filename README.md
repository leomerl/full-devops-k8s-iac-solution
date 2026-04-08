## 01 Create tfstate bucket
* Bootstrap folder will create a shared bucket for your tfstate files 
* Run `terraform plan` and `terraform apply` from folder 01-bootstrap  


## 02 Create K3S
* Create ec2 machine with k3s single node cluster (minimal k8s version)
* Run `export KUBECONFIG=k3s.yaml` to access your new cluster
* Update your IP address in your `terraform.tfvars` 


## 03 Configure cluster
* Add docker.com token: `Account Settings` -> `Personal access tokens`
* Add github.com token: `Security` -> `personal access tokens` -> `Fine-grained tokens`

### Login to Argo

#### Method 1: external IP
Updated link should be in the outputs once `terraform apply` is completed.
`https://argo.<YOURIP>.nip.io`  admin:Aa123456

#### Method 2: Localhost
`kubectl port-forward -n argocd svc/argo-cd-argocd-server  8443:443`

[ArgoCD on https://localhost:8443/applications ](https://localhost:8443/applications) admin:Aa123456

---

### Jenkins
Jenkins will need about 10 minutes to start. Consider the time Argo needs to apply the ApplicationSets, and for Jenkins pod to start.

Open `http://<YOURIP>.nip.io:32001/`  admin:Aa123456

#### Jenkins CasC (Configuration As Code)
Jenkins Support predefined configuration. Include Users, plugins and jobs. 
* [Jenkins CasC Example](https://github.com/elevy99927/argo-demo-repo/blob/application/jenkins/k8s-qa/values.yaml)


---
### Secrets managment
Jenkins need secrets to upload images to [Docker hub](https://hub.docker.io) and push commits to [Github](https://github.com).
<BR> These secrets are defined in `03-cluster-bootstrap/terraform.tfvars`
```
dockerhub_username      = "elevy99927"
dockerhub_token         = ""
github_token            = ""
argocd_admin_password   = ""  # htpasswd -nbBC 10 "" "Aa123456" | tr -d ':\n' 


```

*BUT* there are problems:
* *Problem 1*: Jenkins namespace is not created yet (and maybe never will). The solution is to use [reflector](https://github.com/emberstack/kubernetes-reflector) to sync the `Secrets` from central namespace (e.g. devops-utils) to Namespace `Jenkins` once it's created.
* *Problem 2*: Using reflector require us to create empty secret in the destination namespace. However, ArgoCD will overwrite the secret after reflector will update it. 
<BR> The solution is to create empty [secret](https://github.com/elevy99927/argo-demo-repo/blob/application/jenkins/k8s-qa/secrets/secrets.yaml). For example:

```yaml
apiVersion: v1
kind: Secret
metadata:
 name: docker-cred
 annotations:
   reflector.v1.k8s.emberstack.com/reflects: "devops-utils/docker-cred"
   argocd.argoproj.io/sync-options: Replace=true
   argocd.argoproj.io/compare-option: IgnoreOnDrift
data:

```
