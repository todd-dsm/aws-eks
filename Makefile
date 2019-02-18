#!/usr/bin/env make
# vim: tabstop=8 noexpandtab

# Grab some ENV stuff
TF_VAR_cluster_name	?= $(shell $(TF_VAR_cluster_name))
TF_VAR_envBucket	?= $(shell $(TF_VAR_envBucket))
planFile		?= $(shell $(planFile))

# Start Terraforming
#prep:	## Prepare for the build
#	@setup/create-project-bucket.sh

all: 	tf-init plan apply creds xdns scale observe  ## All-in-one 

tf-init: ## Initialze the build
	date
	terraform init -get=true -backend=true -reconfigure \
		-backend-config="backend.hcl"

plan:   ## Initialze and Plan the build with output log
	terraform plan -no-color \
		-out=$(planFile) 2>&1 | \
		tee /tmp/tf-$(TF_VAR_cluster_name)-plan.out

apply:	## Build Terraform project with output log
	terraform apply --auto-approve -no-color \
		-input=false "$(planFile)" 2>&1 | \
		tee /tmp/tf-$(TF_VAR_cluster_name)-apply.out

creds:	## Update the local KUBECONFIG with the new cluster details
	scripts/get-kubeconfig.sh
	# wait for some pods to start
	scripts/join-workers.sh
	scripts/wait-kube-nodes-ready.sh
	kubectl -n kube-system wait --for=condition=ready pod -l k8s-app=kube-dns --timeout=300s
	helm init
	kubectl create clusterrolebinding tiller-cluster-admin --clusterrole=cluster-admin --serviceaccount=kube-system:default
	helm init --upgrade
	kubectl -n kube-system wait --for=condition=ready pod -l name=tiller --timeout=60s
	scripts/conf-cluster-autoscaler.sh

xdns:   ## installs metrics server
	kubectl create -f addons/xdns/ 

scale:  ## installs metrics server
	helm install stable/metrics-server --name metrics-server \
		--version 2.0.4 --namespace metrics 
	scripts/wait-metrics-server-ready.sh

observe: ## Deploy Datadog
	kubectl create -f addons/datadog/
	date
	
# ------------------------ 'make all' ends here ------------------------------#

graph:  ## Create a visual graph pre-build 
	scripts/graphit.sh

opcon:  ## install opcon helm chart
	curl -Lk https://git.mascorp.com/devops/pac-certs/raw/master/NOC-CA-bundle.pem > /tmp/NOC-CA-bundle.pem
	helm repo add --ca-file /tmp/NOC-CA-bundle.pem gcs https://gcs.git.mascorp.com/helm
	helm repo update
	helm install gcs/opcon --name opcon

ingress: ## install ingress
	kubectl apply -f addons/nginx-ingress/ingress.yml

scaletest: ## Tests HPA scaling
	kubectl run php-apache --image=k8s.gcr.io/hpa-example --requests=cpu=200m --expose --port=80 -l app=php-apache
	kubectl autoscale deployment php-apache --cpu-percent=15 --min=1 --max=10
	screen -dmS hpa bash -c 'kubectl get hpa -w > /tmp/hpa.out'
	screen -dmS pods bash -c 'kubectl get pods -w > /tmp/pods.out'
	#kubectl run -it load-generator --image=busybox --restart=Never --rm -- /bin/sh -c "while true; do wget -q -O - http://php-apache; done"
	#kubectl exec -it load-generator -- /bin/sh -c "while true; do wget -q -O - http://php-apache; done"

scaleresults: ## Prints the scale results
	cat /tmp/hpa.out /tmp/pods.out
	
scaleclean: ## Cleans up the junk created from the scale test
	rm -f /tmp/hpa.out /tmp/pods.out
	screen -X -S hpa quit | true
	screen -X -S pods quit | true
	kubectl delete hpa php-apache | true
	kubectl delete svc php-apache | true
	kubectl delete pod load-generator | true
	kubectl delete deployment php-apache | true
	#scripts/load-un.sh

apm: ## Deploys todo demo app with Datadog APM integration
	curl -Lk https://git.mascorp.com/devops/pac-certs/raw/master/NOC-CA-bundle.pem > /tmp/NOC-CA-bundle.pem
	helm repo add --ca-file /tmp/NOC-CA-bundle.pem devops https://devops.git.mascorp.com/helm
	helm repo update
	helm install devops/datadog-apm-demo-app --name apm-demo

clean:	## Destroy Terraformed resources and all generated files with output log
	date
	helm del $$(helm ls --all --short) --purge | true
	sleep 5
	terraform destroy --force -no-color 2>&1 | \
		tee /tmp/tf-$(TF_VAR_cluster_name)-destroy.out
	rm -f "$(planFile)"
	rm -f secrets/pac-stage-master.p*		# FIXME; variablize
	rm -rf .terraform
	kubectl config use-context minikube
	kubectl config delete-context $(TF_VAR_cluster_name)
	#aws s3 rm --recursive s3://$(TF_VAR_envBucket)
#	@sudo lsof -i :8001 | grep IPv4 | awk '{print $2}' | grep kubectl  | \
#	       	xargs kill -9 > /dev/null
	date

reset:	## clear-off kubeconfig cruft
	kubectl config use-context minikube
	kubectl config delete-context kubes-stage-va

#-----------------------------------------------------------------------------#
#------------------------   MANAGERIAL OVERHEAD   ----------------------------#
#-----------------------------------------------------------------------------#
print-%  : ## Print any variable from the Makefile (e.g. make print-VARIABLE);
	@echo $* = $($*)

.PHONY: help

help:
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-16s\033[0m %s\n", $$1, $$2}'

.DEFAULT_GOAL := help

