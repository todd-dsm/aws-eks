#!/usr/bin/env bash
#  PURPOSE: QnD/1-time generation of all certs. WARNING, THIS PROCESS:
#             * IS NOT TO BE USED IN PRODUCTION
#             * WILL STOMP OLD CERTS FROM PREVIOUS RUNS
# -----------------------------------------------------------------------------
#  PREREQS: a) brew install cfssl
#           b) service must have a config file in: (example)
#               addons/cert-conf/vault-csr.json
#           c)
# -----------------------------------------------------------------------------
#  EXECUTE:
# -----------------------------------------------------------------------------
#     TODO: 1)
#           2)
#           3)
# -----------------------------------------------------------------------------
#   AUTHOR: Todd E Thomas
# -----------------------------------------------------------------------------
#  CREATED: 2018/09/00
# -----------------------------------------------------------------------------
set -x


###----------------------------------------------------------------------------
### VARIABLES
###----------------------------------------------------------------------------
# ENV Stuff
declare -a certList=('vault' 'consul' 'metrics')

# Data Files
certsConf='addons/cert-conf'
certsDir='secrets/certs'


###----------------------------------------------------------------------------
### FUNCTIONS
###----------------------------------------------------------------------------


###----------------------------------------------------------------------------
### MAIN PROGRAM
###----------------------------------------------------------------------------
### Gen all certs in the array
###---
printf '\n\n%s\n' "Print all elements in the array..."
for tlsCert in "${certList[@]}"; do
    printf '%s\n\n' "  Creating cert for $tlsCert..."
    cfssl gencert -ca="${certsDir}/ca.pem" -ca-key="${certsDir}/ca-key.pem" \
        -config="${certsConf}/ca-config.json" -profile=default \
        "${certsConf}/${tlsCert}-csr.json" | cfssljson -bare "${certsDir}/${tlsCert}"
done


###---
### REQ
###---


###---
### REQ
###---


###---
### fin~
###---
exit 0
