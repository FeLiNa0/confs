#!/bin/sh
set -x

# This downloads some configs from Omni/Sidero for dev/stg/prd

cd ~/.kube/
omnictl config context dev
generate_kubeconfigs.sh '0007|1002|0137|1337|0007-58|0007-04|0007-13|0007-629-max|0001-31-leghorn|0007-25-nico'

# # stage not stg, thank you sidero/omni/etc
omnictl config context stg
generate_kubeconfigs.sh '0001-12|0007-629|0008-03'
# 
omnictl config context prd
generate_kubeconfigs.sh '0018|0060|0001|0077|0117'

# This merges all .yaml files in ~/.kube into one single kubeconfig.
# Switch configs with kubectx or with `kubectl config`.
KUBECONFIG="$HOME/.kube/config":$(find "$HOME/.kube" -type f -iname \*.yaml | tr '\n' ':') kubectl config view --flatten > "$HOME/.kube/config"

gcloud container clusters get-credentials --region us-west2 powerflex-small-scale-cluster  --project powerflex-small-scale-dev-7fa9
gcloud container clusters get-credentials --region us-west2 powerflex-small-scale-cluster  --project powerflex-small-scale-stg-5025
gcloud container clusters get-credentials --region us-west2 gke-stg-powerflex-cluster --project edf-re-powerflex-stg-8019
gcloud container clusters get-credentials --region us-west2 gke-dev-powerflex-cluster --project edf-re-powerflex-dev-16b1
gcloud container clusters get-credentials --region us-west2 nats-perf-cluster --project powerflex-nats-perf-dev-7102
gcloud container clusters get-credentials --region us-west2 gke-sim-powerflex-cluster --project edf-re-powerflex-sim-ada8 
gcloud container clusters get-credentials --region us-west2 gke-sim-powerflex-edge-cluster --project edf-re-powerflex-sim-ada8 
