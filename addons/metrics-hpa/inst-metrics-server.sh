#!/usr/bin/env bash

helm install stable/metrics-server \
    --name metrics-server \
    --version 2.0.4 \
    --namespace kube-system

# Confirm all is running and available
sleep 5
kubectl get apiservice v1beta1.metrics.k8s.io -o yaml
