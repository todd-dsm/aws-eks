#!/usr/bin/env bash
#set -x

JSONPATH='{range .items[*]}{@.metadata.name}:{range @.status.conditions[*]}{@.type}={@.status};{end}{end}'

function yo() {
    kubectl get nodes -o jsonpath="$JSONPATH" | grep -c "Ready=False"
}
# wait for all nodes to get out of the not ready false state
#kubectl get nodes -o jsonpath="$JSONPATH" | grep "Ready=False"
#while [ $? -eq 0 ]; do !!; done

#while kubectl get nodes -o jsonpath="$JSONPATH" | grep "Ready=False" == 1; do
while [[ "$(kubectl get nodes -o jsonpath="$JSONPATH" | grep -c "Ready=False")" == 1 ]]; do
    sleep 1
done


# Kubernetes-view of the nodes
kubectl get nodes

aws ec2 describe-instances   \
    --query "Reservations[*].Instances[*].PublicIpAddress" \
    --output=text > /tmp/workers.out

set +x
