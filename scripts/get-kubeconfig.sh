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
awsAuthVers='1.11.5'
awsAuthDate='2018-12-06'
tmpAuthBin='/tmp/aws-iam-authenticator'
sysAuthBin='/usr/local/bin/aws-iam-authenticator'
tmpAuthSHA='/tmp/aws-iam-authenticator.sha256'
remoteAuthBin="https://amazon-eks.s3-us-west-2.amazonaws.com/${awsAuthVers}/${awsAuthDate}/bin/darwin/amd64/aws-iam-authenticator"
remoteAuthSHA="https://amazon-eks.s3-us-west-2.amazonaws.com/${awsAuthVers}/${awsAuthDate}/bin/darwin/amd64/aws-iam-authenticator.sha256"
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
if ! type -P "${sysAuthBin##*/}"; then
    pMsg "The AWS Authenticator is not installed; pulling it..."
    pMsg "Instructions: $iamAuthURL"
    curl -so "$tmpAuthBin" "$remoteAuthBin"
    pMsg "Validating the bin with the SHA-256 sum..."
    curl -so "$tmpAuthSHA" "$remoteAuthSHA"
    shaTarget="$(cut -d' ' -f1 "$tmpAuthSHA")"
    shaActual="$(openssl sha -sha256 "$tmpAuthBin")"
    if [[ "${shaActual##*\ }" != "$shaTarget" ]]; then
        pMsg "The download flaked; check the instructions above; I'm out."
        exit 1
    else
        pMsg "The download was good, moving it home..."
        mv "$tmpAuthBin" "$sysAuthBin"
        chmod u+x "$sysAuthBin"
    fi
else
    pMsg "There is an authenticator; moving on."
fi


###---
### Display the actual credentials
###---
#pMsg """
#
#    We'll attempt to get the EKS config with these credentials:
#
#    """
#aws sts get-caller-identity


###---
### Update the local KUBECONFIG with the new, remote cluster details
### REF: https://docs.aws.amazon.com/eks/latest/userguide/create-kubeconfig.html
###---

targetClusterName="$(grep "name: $TF_VAR_cluster_name" ~/.kube/config)"

if [[ "${targetClusterName##* }" != "$TF_VAR_cluster_name" ]]; then
    pMsg """

        Updating local KUBECONFIG...

        """
    aws eks update-kubeconfig --name "$TF_VAR_cluster_name"
else
    pMsg """

        It looks like $TF_VAR_cluster_name is configured; I'm out.

        """
        exit 0
fi

###---
### Change the Cluster Name locally
###---
pMsg """

    Changing that obnoxious name...

    """
kubectl config rename-context \
	"arn:aws:eks:${TF_VAR_region}:405322537961:cluster/${TF_VAR_cluster_name}" \
	"$TF_VAR_cluster_name"


###---
### REQ
###---
pMsg """

    The new contexts:

    """
kubectl config get-contexts
kubectl config use-context  "$TF_VAR_cluster_name"


###---
### REQ
###---
pMsg """

    The new EKS Cluster:

    """
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
