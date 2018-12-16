#!/usr/bin/env bash
# shellcheck disable=SC2154
#  PURPOSE: Update the local kube-config file with the new EKS cluster.
# -----------------------------------------------------------------------------
#  PREREQS: a) the 'aws-iam-authenticator' must be installed; REF:
#           b)
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
#  CREATED: 2018/10/00
# -----------------------------------------------------------------------------
#set -x


###----------------------------------------------------------------------------
### VARIABLES
###----------------------------------------------------------------------------
#"${1?  Wheres my first agument, bro!}"
# ENV Stuff
iamAuthURL='https://docs.aws.amazon.com/eks/latest/userguide/configure-kubectl.html'
# Data


###----------------------------------------------------------------------------
### FUNCTIONS
###----------------------------------------------------------------------------
function pMsg() {
    theMessage="$1"
    printf '%s\n' "$theMessage"
}

###----------------------------------------------------------------------------
### MAIN PROGRAM
###----------------------------------------------------------------------------
### Check basic requirements
###---
if ! type -P aws-iam-authenticator; then
    pMsg "The AWS Authenticator is not installed; I'm out!"
    pMsg "Instructions: $iamAuthURL"
    exit 1
fi




###---
###
###---
pMsg "We'll attempt to get the EKS config with these credentials:"
aws sts get-caller-identity


###---
### Update the local KUBECONFIG with the new, remote cluster details
### REF: https://docs.aws.amazon.com/eks/latest/userguide/create-kubeconfig.html
###---
pMsg "Updating local ${KUBECONFIG##*.}..."
aws eks update-kubeconfig --name "$TF_VAR_cluster_name"


###---
### Change the Cluster Name locally
###---
pMsg "Changing that obnoxious name..."
kubectl config rename-context \
	"arn:aws:eks:${TF_VAR_region}:405322537961:cluster/${TF_VAR_cluster_name}" \
	"$TF_VAR_cluster_name"


###---
### REQ
###---
pMsg "The new contexts:"
kubectl config get-contexts
kubectl config use-context  "$TF_VAR_cluster_name"


###---
### REQ
###---
pMsg "The new EKS Cluster:"
kubectl cluster-info


###---
### REQ
###---


###---
### REQ
###---


###---
### REQ
###---


###---
### REQ
###---


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
