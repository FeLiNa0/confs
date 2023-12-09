#!/bin/sh
set -x

# This downloads some configs from Omni/Sidero for dev/stg/prd
cd ~/.kube/
omnictl config context dev
generate_kubeconfigs.sh '0007-04|0007-13-morley|0007-629-max|0001-31-leghorn|0007-25-nico'

# # stage not stg, thank you sidero/omni/etc
# omnictl config context stage
# generate_kubeconfigs.sh '0001-12|0007-629-max|0008-03|0001-31-integration-stall'
# 
# omnictl config context prd
# generate_kubeconfigs.sh '0001|0077'

# This merges all .yaml files in ~/.kube into one single kubeconfig.
# Switch configs with kubectx or with `kubectl config`.
KUBECONFIG="$HOME/.kube/config":$(find "$HOME/.kube" -type f -iname \*.yaml | tr '\n' ':') kubectl config view --flatten > "$HOME/.kube/config"

gcloud container clusters get-credentials powerflex-small-scale-cluster  --region us-west2 --project powerflex-small-scale-dev-7fa9
gcloud container clusters get-credentials powerflex-small-scale-cluster  --region us-west2 --project powerflex-small-scale-stg-5025
gcloud container clusters get-credentials gke-stg-powerflex-cluster --region us-west2 --project edf-re-powerflex-stg-8019
gcloud container clusters get-credentials gke-dev-powerflex-cluster --region us-west2 --project edf-re-powerflex-dev-16b1
gcloud container clusters get-credentials nats-perf-cluster --region us-west2 --project powerflex-nats-perf-dev-7102
