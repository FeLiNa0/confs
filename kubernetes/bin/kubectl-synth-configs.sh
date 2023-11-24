#!/bin/sh
set -x

KUBECONFIG="$HOME/.kube/config":$(find "$HOME/.kube" -type f -iname \*.yaml | tr '\n' ':') kubectl config view --flatten > "$HOME/.kube/config"

gcloud container clusters get-credentials powerflex-small-scale-cluster  --region us-west2 --project powerflex-small-scale-dev-7fa9
gcloud container clusters get-credentials gke-stg-powerflex-cluster --region us-west2 --project edf-re-powerflex-stg-8019
gcloud container clusters get-credentials gke-dev-powerflex-cluster --region us-west2 --project edf-re-powerflex-dev-16b1
