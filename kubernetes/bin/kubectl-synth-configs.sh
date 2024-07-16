#!/bin/sh
set -x

# This downloads some configs from Omni/Sidero for dev/stg/prd

cd ~/.kube/
omnictl config context dev
# generate_kubeconfigs.sh '0007|1002|0137|1337|0007-58|0007-04|0007-13|0007-629-max|0001-31-leghorn|0007-25-nico'

# # stage not stg, thank you sidero/omni/etc
# omnictl config context stg
# generate_kubeconfigs.sh '0001-12|0007-629|0008-03|0137|9137'

# prd
omnictl config context prd
generate_kubeconfigs.sh '0018|0060|0001|0008|0077|0117|0137|9137'

# This merges all .yaml files in ~/.kube into one single kubeconfig.
# Switch configs with kubectx or with `kubectl config`.
KUBECONFIG="$HOME/.kube/config":$(find "$HOME/.kube" -type f -iname \*.yaml | tr '\n' ':') kubectl config view --flatten > "$HOME/.kube/config"

# GKE Cloud
gcloud container clusters get-credentials --region us-west2 gke-stg-powerflex-cluster --project edf-re-powerflex-stg-8019
gcloud container clusters get-credentials --region us-west2 gke-dev-powerflex-cluster --project edf-re-powerflex-dev-16b1

# GKE Cloud Nexus
gcloud container clusters get-credentials --region us-west2 gke-dev-powerflex-cloud-nexus --project powerflex-cloud-nexus-dev
gcloud container clusters get-credentials --region us-west2 gke-stg-powerflex-cloud-nexus --project powerflex-cloud-nexus-stg
gcloud container clusters get-credentials --region us-west2 gke-prd-powerflex-cloud-nexus --project powerflex-cloud-nexus-prd
