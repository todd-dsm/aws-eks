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
# ENV Stuff
: "${TF_VAR_cluster_name?  Wheres cluster_name, bro!}"
: "${TF_VAR_aws_acct_no?   Missing the account number!}"

myRegion="$TF_VAR_region"
myAcctNo="$TF_VAR_aws_acct_no"
myCluster="cluster/${TF_VAR_cluster_name}"
eksCluster="arn:aws:eks:${myRegion}:${myAcctNo}:${myCluster}"
targetClusterName="$(grep "name: $TF_VAR_cluster_name" ~/.kube/config)"

###----------------------------------------------------------------------------
### FUNCTIONS
###----------------------------------------------------------------------------
# print a 1-liner
function pMsg() {
    theMessage="$1"
    printf '\n%s\n\n' "$theMessage"
}

# grab someones attention
function pHeadline() {
    theMessage="$1"
    printf '%s\n' """
                    $theMessage
    """
}

# rename cloud-defaults, they're way too long
function renameCreds() {
    pMsg "Changing that obnoxious name..."
    kubectl config rename-context "$eksCluster" "$TF_VAR_cluster_name"
}

# no creds locally, get them
function pullNewCreds() {
    pHeadline "No config found; pulling new..."
    aws eks update-kubeconfig \
        --name "$TF_VAR_cluster_name" \
        --region="$TF_VAR_region"
    renameCreds
}


###----------------------------------------------------------------------------
### MAIN PROGRAM
###----------------------------------------------------------------------------
### Update the local KUBECONFIG with the new, remote cluster details
### REF: https://docs.aws.amazon.com/eks/latest/userguide/create-kubeconfig.html
###---
#targetClusterName="$eksCluster"
#targetClusterName="foo"
targetClusterName=""

case "${targetClusterName##* }" in
    "")
        pullNewCreds
        ;;
    "$TF_VAR_cluster_name")
        echo "REQ further checks"
        ;;
    "$eksCluster")
        renameCreds
        ;;
    *)  # Default case: If no more options then break out of the loop.
        pHeadline "Slack the DevOps team for help with this exception."
        #printf '\n%s\n\n' "  Slack the DevOps team for help with this exception."
        ;;
esac


###---
### Disaply all contexts, switch to this cluster
###---
pHeadline "The new contexts:"

kubectl config get-contexts
kubectl config use-context  "$TF_VAR_cluster_name"


###---
### Disaply current cluster info
###---
pHeadline "The new EKS Cluster:"
kubectl cluster-info


###---
### REQ
###---


###---
### fin~
###---
exit 0
