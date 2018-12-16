#!/usr/bin/env bash
# shellcheck disable=SC2154
#  PURPOSE: Creates an AWS S3 Bucket for remote terraform state storage.
#           Intended for use with DynamoDB to support state locking and
#           consistency checking.
#
#           Managing the S3 and Backend config in the same file ensures
#           consistent bucket naming. S3 bucket = backend bucket. To guard
#           against errors, these should not be separated.
# -----------------------------------------------------------------------------
#  PREREQS: a) The bucket must exist before initializing the backend.
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
#  CREATED: 2018/12/09
# -----------------------------------------------------------------------------
#set -x


###----------------------------------------------------------------------------
### VARIABLES
###----------------------------------------------------------------------------
# ENV Stuff
: "${TF_VAR_envBucket?  Whats the bucket name, bro?!}"

# Files
backendDef='backend.tf'
#backendS3Def='state_remote_s3.tf'


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
### Setup Terraform state storage
###---
printf '\n\n%s\n' "Creating a bucket for remote terraform state..."
# Bucket name must be unique to all bucket names
aws s3 mb "s3://${TF_VAR_envBucket}"


###---
### BACKEND: Create the Terraform backend definition
###---
cat > "$backendDef" <<EOF
/*
  -----------------------------------------------------------------------------
                           CENTRALIZED HOME FOR STATE
                           inerpolations NOT allowed
  -----------------------------------------------------------------------------
*/
backend "s3" {
  key     = "state/${TF_VAR_envBuild}"
  region  = "$TF_VAR_region"
  encrypt = true
  #dynamodb_table = "tf-state-lock-table"

  # MUST BE THE SAME AS 'state_remote_s3.tf: bucket'
  bucket = "${TF_VAR_envBucket}"
}

EOF


###---
### BACKEND: Create the Terraform bucket definition
###---
#cat > "$backendS3Def" <<EOF
#/*
#  -----------------------------------------------------------------------------
#                             REMOTE STATE STORAGE
#  -----------------------------------------------------------------------------
#*/
#resource "aws_s3_bucket" "terraform-state-storage" {
#  bucket = "${TF_VAR_envBucket}"
#
#  versioning {
#    enabled = true
#  }
#
#  lifecycle {
#    prevent_destroy = true
#  }
#
#  tags {
#    Name = "S3 Remote TF State Store ${TF_VAR_envBuild} ${TF_VAR_project}"
#  }
#}
#EOF


###---
### Make the announcement
###---
printf '\n\n%s\n\n' "We're ready to start Terraforming!"


###---
### fin~
###---
exit 0
