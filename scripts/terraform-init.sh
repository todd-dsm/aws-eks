#!/usr/bin/env bash
# Dynamo Tables:
#   * pac.terraform
#   * pac.terraform.stage

###---
### Variables
###---
### Verify a base constant
:"${TF_VAR_envBuild? Get the variables; E.G.: source setup/build.env stage}"

# Initialize and setup the backend
# With Dynamo
#terraform init -backend=true -backend-config="remote.$TF_VAR_envBuild.hcl"

# With S3 Bucket
terraform init -backend=true -backend-config="remote.$TF_VAR_envBuild.hcl"
