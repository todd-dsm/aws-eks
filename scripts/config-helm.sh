#!/usr/bin/env bash

# Create ServiceAccount and ClusterRoleBinding for Helm Tiller
kubectl create -f addons/helm/tiller-rbac.yaml

# Deploy Tiller
helm init --service-account tiller

