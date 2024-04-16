/*resource "null_resource" "argocd-ck" {
  provisioner "local-exec" {
    command = <<EOT
    export KUBECONFIG=~/.kube/cryptk8s
    EOT
  }
  depends_on = [var.eks-name]
}*/

resource "kubernetes_namespace" "argocd" {
  metadata {
    name = "argocd${lower(var.environment)}"
  }
  depends_on = [var.eks-name]
}

resource "helm_release" "argocd-dev" {
  name       = "argocd${lower(var.environment)}"
  chart      = "argo-cd"
  repository = "https://argoproj.github.io/argo-helm"
  version    = "6.7.3" # argocd latest current version
  create_namespace = true
  namespace  = "argocd-${lower(var.environment)}"
  timeout    = "1200"
  values     = [templatefile("./argocd/values/install.yaml", {})]
  depends_on = [kubernetes_namespace.argocd]
}

/*resource "null_resource" "argocd-namespace" {
  provisioner "local-exec" {
    working_dir = "./argocd"
    #command     = "export KUBECONFIG=~/.kube/cryptk8s && kubectl create namespace argocd"

    command = <<EOT
    export KUBECONFIG=~/.kube/cryptk8s && \
    kubectl create namespace argocd && \
    kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
    EOT
    interpreter = ["/bin/bash", "-c"]
  }
  depends_on = [var.eks-name]
}
*/
resource "null_resource" "argocd-password" {
  provisioner "local-exec" {
    working_dir = "./argocd"
    command = <<EOT
    export KUBECONFIG=~/.kube/cryptk8s && \
    kubectl -n argocd-${lower(var.environment)} get secret argocd-initial-admin-secret -o jsonpath={.data.password} | base64 -d > argocd-login.txt
    EOT
    interpreter = ["/bin/bash", "-c"]
  }
  depends_on = [helm_release.argocd-dev]
}

resource "null_resource" "argocd-patch" {
  provisioner "local-exec" {
    command = <<EOT
    export KUBECONFIG=~/.kube/cryptk8s && \
    kubectl patch svc ${helm_release.argocd-dev.name}-server -n ${helm_release.argocd-dev.namespace} -p '{"spec": {"type": "LoadBalancer"}}'
    EOT
    interpreter = ["/bin/bash", "-c"]
  }
  depends_on = [null_resource.argocd-password]
}



/*resource "null_resource" "argocd-deploy-in-eks" {
  provisioner "local-exec" {
    working_dir = "./argocd"
    command     = "export KUBECONFIG=~/.kube/cryptk8s && kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml"
  }
  depends_on = [null_resource.argocd-namespace]
}

resource "null_resource" "password" {
  provisioner "local-exec" {
    working_dir = "./argocd"
    command     = "export KUBECONFIG=~/.kube/cryptk8s && kubectl -n argocd-${lower(var.environment)} get secret argocd-initial-admin-secret -o jsonpath={.data.password} | base64 -d > argocd-login.txt"
  }
  depends_on = [null_resource.argocd-deploy-in-eks]
}

resource "null_resource" "argocd-port-forwarding" {
  provisioner "local-exec" {
    working_dir = "./argocd"
    command     = "export KUBECONFIG=~/.kube/cryptk8s && kubectl port-forward svc/argocd-server -n argocd 8080:443"
  }
  depends_on = [null_resource.password]
}
*/

#resource "null_resource" "del-argo-pass" {
#  depends_on = [null_resource.password]
#  provisioner "local-exec" {
#    command = "kubectl -n argocd-${var.environment} delete secret argocd-initial-admin-secret"
#  }
#}