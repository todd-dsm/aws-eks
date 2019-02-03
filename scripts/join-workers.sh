#!/usr/bin/env bash
set -ex

workerConfig='/tmp/config_map_aws_auth.yaml'

# output workers configmap
terraform output worker-configmap > "$workerConfig"

# join workers
kubectl apply -f "$workerConfig"
