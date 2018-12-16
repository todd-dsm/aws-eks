#!/usr/bin/env bash
set -ex

workerConfig='/tmp/config_map_aws_auth.yaml'

# output workers configmap
terraform output config_map_aws_auth > "$workerConfig"

# join workers
kubectl apply -f "$workerConfig"
