/*resource "kubernetes_namespace" "tekton" {
  metadata {
    name = "tekton${lower(var.environment)}"
  }
  depends_on = [var.eks-name]
}*/

/*
resource "helm_release" "tekton-dev" {
  name             = "tekton-pipelines"
  #repository       = "https://cdfoundation.github.io/tekton-helm-chart/"
  #repository       = "https://tekton-charts.storage.googleapis.com"
  repository        =  "https://cdfoundation.github.io/tekton-helm-chart/"
  #repository       = "https://charts.helm.sh/stable"
  #"https://tekton-releases.github.io/pipeline"
  create_namespace = true
  namespace        = "tekton-pipeline"
  chart            = "tekton-pipeline"
  #version          = "7.0.6"
  #name       = "tekton_dashboard"
}*/


resource "null_resource" "tekton-deploy" {
  provisioner "local-exec" {
    command = <<EOT
    export KUBECONFIG=~/.kube/cryptk8s && \
    kubectl apply -f https://storage.googleapis.com/tekton-releases/pipeline/latest/release.yaml && \
    kubectl apply -f https://storage.googleapis.com/tekton-releases/operator/latest/release.yaml && \
    kubectl apply -f https://storage.googleapis.com/tekton-releases/chains/latest/release.yaml && \
    kubectl apply -f https://storage.googleapis.com/tekton-releases/dashboard/latest/release.yaml && \
    kubectl apply -f https://storage.googleapis.com/tekton-releases/triggers/latest/release.yaml && \
    kubectl apply -f https://storage.googleapis.com/tekton-releases/triggers/latest/interceptors.yaml
    EOT
    interpreter = ["/bin/bash", "-c"]
  }
  depends_on = [var.eks-name]
}
# 
# export KUBECONFIG=~/.kube/cryptk8s && \
#kubectl apply -f https://storage.googleapis.com/tekton-releases/pipeline/latest/release.yaml && \
    #kubectl apply --filename https://storage.googleapis.com/tekton-releases/dashboard/latest/release.yaml