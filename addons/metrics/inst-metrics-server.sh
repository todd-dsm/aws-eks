#!/usr/bin/env bash
set -x

certsDir='secrets/certs'

kubectl create secret generic metrics-server    \
    --namespace=metrics-server                  \
    --from-file="${certsDir}/ca.pem"            \
    --from-file="${certsDir}/metrics.pem"       \
    --from-file="${certsDir}/metrics-key.pem"
