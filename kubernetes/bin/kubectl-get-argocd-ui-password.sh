#!/bin/sh
echo Remember to port forward the UI with >&2
echo kubectl port-forward svc/argocd-server -n argocd 8080:80 >&2
set -x
# kubectl get secret argocd-cluster -n argocd -o jsonpath='{.data.admin\.password}' | base64 --decode
# This is just the password hash, don't want this
# kubectl get secret argocd-secret -n argocd -o jsonpath='{.data.admin\.password}' | base64 --decode
kubectl get secret argocd-initial-admin-secret -n argocd -o jsonpath='{.data.password}' | base64 --decode
