#!/usr/bin/env bash
#  PURPOSE: waits for metrics to surface, displays them and exits.
# -----------------------------------------------------------------------------
#  PREREQS: a) install kubectl
#           b) a functional kubernetes cluster
#           c)
# -----------------------------------------------------------------------------
#  EXECUTE: scripts/wait-metrics-server-ready.sh
# -----------------------------------------------------------------------------
#     TODO: 1)
#           2)
#           3)
# -----------------------------------------------------------------------------
#   AUTHOR: Todd E Thomas
# -----------------------------------------------------------------------------
#  CREATED: 2019/02/03
# -----------------------------------------------------------------------------
#set -x


###----------------------------------------------------------------------------
### VARIABLES
###----------------------------------------------------------------------------


###----------------------------------------------------------------------------
### FUNCTIONS
###----------------------------------------------------------------------------


###----------------------------------------------------------------------------
### MAIN PROGRAM
###----------------------------------------------------------------------------
### wait for metrics to bubble up
###---
while [[ -z "$(kubectl top node)" ]] > /dev/null 2>&1; do
    printf '%s\n' "Waiting for metrics..."
    sleep 10
done


###---
### Make the announcement
###---
printf '%s\n' """

    We have metrics!

    """

kubectl get --raw "/apis/metrics.k8s.io/v1beta1/nodes"


###---
### Display current per-node metrics
###---
printf '%s\n' """

    Per-node metrics!

    """

kubectl top node


###---
### REQ
###---


###---
### fin~
###---
exit 0
