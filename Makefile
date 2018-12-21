#!/usr/bin/env make
# vim: tabstop=8 noexpandtab

# Grab some ENV stuff
TF_VAR_cluster_name	?= $(shell $(TF_VAR_cluster_name))
TF_VAR_envBucket	?= $(shell $(TF_VAR_envBucket))
planFile		?= $(shell $(planFile))

# Start Terraforming
#prep:	## Prepare for the build
#	@setup/create-project-bucket.sh

tf-init: ## Initialze the build
	terraform init -get=true -backend=true \
		-backend-config="backend.hcl"

plan:   ## Initialze and Plan the build with output log
	terraform plan -no-color \
		-out=$(planFile) 2>&1 | \
		tee /tmp/tf-$(TF_VAR_cluster_name)-plan.out

graph:  ## Create a visual graph pre-build 
	scripts/graphit.sh

apply:	## Build Terraform project with output log
	terraform apply --auto-approve -no-color \
		-input=false "$(planFile)" 2>&1 | \
		tee /tmp/tf-$(TF_VAR_cluster_name)-apply.out
	cp -vp ./terraform.tfstate /tmp/

creds:	## Update the local KUBECONFIG with the new cluster details
	scripts/get-kubeconfig.sh
	scripts/join-workers.sh

remote:	## Switch to remote state storage
	terraform init -get=true -backend=true \
		-backend-config="backend.hcl"
	
#dashboard: ## proxy out the cluster for Dashboard access
#	scripts/admin.sh
#
clean:	## Destroy Terraformed resources and all generated files with output log
	terraform destroy --force -auto-approve -no-color 2>&1 | \
		tee /tmp/tf-$(TF_VAR_cluster_name)-destroy.out
	kubectl config use-context minikube
	kubectl config delete-context $(TF_VAR_cluster_name)
	rm -f "$(planFile)"
	rm -rf .terraform
	rm -f  terraform.tfstate*
	#aws s3 rm --recursive s3://$(TF_VAR_envBucket)
	#aws s3 rb s3://$(TF_VAR_envBucket)
#	kubectl config delete-context $(TF_VAR_cluster_name)
#	gcloud compute config-ssh --remove
#	@sudo lsof -i :8001 | grep IPv4 | awk '{print $2}' | grep kubectl  | \
#	       	xargs kill -9 > /dev/null

#-----------------------------------------------------------------------------#
#------------------------   MANAGERIAL OVERHEAD   ----------------------------#
#-----------------------------------------------------------------------------#
print-%  : ## Print any variable from the Makefile (e.g. make print-VARIABLE);
	@echo $* = $($*)

.PHONY: help

help:
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-16s\033[0m %s\n", $$1, $$2}'

.DEFAULT_GOAL := help

