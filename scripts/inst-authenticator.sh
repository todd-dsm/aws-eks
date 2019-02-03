#!/usr/bin/env bash
# shellcheck disable=SC2154
#  PURPOSE: Update the local kube-config file with the new EKS cluster.
# -----------------------------------------------------------------------------
#  PREREQS: a)  must have an IAM account
#           b)  awscli is installed/configured locally
#           c)  the 'aws-iam-authenticator' must be installed; REF:
#               https://goo.gl/d9EnYf
# -----------------------------------------------------------------------------
#  EXECUTE:
# -----------------------------------------------------------------------------
#     TODO: 1) should remove old versions before installing new ones
#           2)
#           3)
# -----------------------------------------------------------------------------
#   AUTHOR: Todd E Thomas
# -----------------------------------------------------------------------------
#  CREATED: 2019/01/19
# -----------------------------------------------------------------------------
#set -x


###----------------------------------------------------------------------------
### VARIABLES
###----------------------------------------------------------------------------
awsAuthVers='1.11.5'
awsAuthDate='2018-12-06'
tmpAuthBin='/tmp/aws-iam-authenticator'
sysAuthBin='/usr/local/bin/aws-iam-authenticator'
tmpAuthSHA='/tmp/aws-iam-authenticator.sha256'
remoteAuthBin="https://amazon-eks.s3-us-west-2.amazonaws.com/${awsAuthVers}/${awsAuthDate}/bin/darwin/amd64/aws-iam-authenticator"
remoteAuthSHA="https://amazon-eks.s3-us-west-2.amazonaws.com/${awsAuthVers}/${awsAuthDate}/bin/darwin/amd64/aws-iam-authenticator.sha256"
iamAuthURL='https://docs.aws.amazon.com/eks/latest/userguide/configure-kubectl.html'


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
    pMsg "The authenticator is already installed."
fi


###---
### REQ
###---


###---
### fin~
###---
exit 0
