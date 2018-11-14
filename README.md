# Terraform for EKS
A terraform script to spin up EKS cluster, including worker nodes

## Getting Started

- Setup EKS cluster & nodegroup
```shell
# download required providers
$ terraform init
Initializing modules...
- module.network
  Getting source "./modules/network"
- module.eks_master
...
Terraform has been successfully initialized!

# update required parameters
$ cp terraform.tfvars.sample terraform.tfvars
$ vim terraform.tfvars

# enter SSH key pair and check aws resources to be created
$ terraform plan
var.key_pair_name
  SSH key pair for instance access
  Enter a value: xxx

Refreshing Terraform state in-memory prior to plan...
The refreshed state will be used to calculate this plan, but will not be
persisted to local or remote state storage.
...
Plan: 52 to add, 0 to change, 0 to destroy.

# start to create Kubernetes cluster
$ terraform apply
var.key_pair_name
  SSH key pair for instance access
  Enter a value: xxx

data.template_file.alb_ingress_policy: Refreshing state...
data.aws_iam_policy_document.workers_assume_role_policy: Refreshing state...
data.aws_iam_policy_document.cluster_assume_role_policy: Refreshing state...
...
Apply complete! Resources: 52 added, 0 changed, 0 destroyed.

Outputs:

cluster_id = learnk8s-dev
worker_subnet_ids = subnet-xxx,subnet-xxx,subnet-xxx
```

- Ensure worker nodes are ready

The kubeconfg file is saved in `.terraform/kubeconfig`, export as env var on shell
```
$ export KUBECONFIG=.terraform/kubeconfig
```

Show the nodes available on the cluster
```
$ kubectl get nodes -w
NAME                                       STATUS    ROLES     AGE       VERSION
ip-10-0-70-17.eu-west-1.compute.internal   Ready     <none>    35s       v1.10.3
```

## Setup for alb-ingress-controller

- Setup [Helm](https://helm.sh/) in k8s cluster
```
$ kubectl create serviceaccount tiller --namespace kube-system
$ echo "apiVersion: v1
kind: ClusterRoleBinding
apiVersion: rbac.authorization.k8s.io/v1beta1
metadata:
  name: tiller-role-binding
roleRef:
  kind: ClusterRole
  name: cluster-admin
  apiGroup: rbac.authorization.k8s.io
subjects:
- kind: ServiceAccount
  name: tiller
  namespace: kube-system" | kubectl apply -f -

$ helm init --service-account tiller
```

- Setup [ingress-nginx](https://github.com/kubernetes/ingress-nginx/)

```
helm install stable/nginx-ingress \
  --name my-nginx
  --set rbac.create=true
  --namespace ingress-nginx
```

- Setup [external-dns](https://github.com/kubernetes-incubator/external-dns)
