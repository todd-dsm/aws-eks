# aws-eks

This is a QnD EKS Kubernetes build with a demo app.

# Leftovers
When this is over there will be:
* A functional [EKS Cluster] with a [NodeAutoScalingGroup]
* build pattern which, I'm not proud of but, illustrates a flow.
* templated setup for quick building


_**NOTE:**_ think about the names you assign to projects; they shouldn't be too revealing.

# Installs
To get going, we need a few things:

[Homebrew] after all, we're not savages.

```
brew install python   # installs python3
pip3 install -U awscli
brew install terraform
```
_*python2 [expires soon]_


Also: install the [aws-iam-authenticator] for Amazon EKS; just download it from the AWS page.

## Do the Work

_**NOTES:**_
* this should be done in 1 shell - until we need a second one.
* if you see anything weird, check the issues in this repo, even the closed ones.

`git clone git@github.com:todd-dsm/aws-eks.git && cd aws-eks`

**Project Details**

Configure the project details in `build.env` then source them into your environment by passing an argument to the script. The argument is your deployment environment; E.G.: stage, prod.

```
source scripts/setup/build.env stage
```

Check the output and verify everything.


**Make the Project**
For reasons you'll come to find on your own, the Terraform bits have been abstracted away to a `Makefile`. Running the `make` command should output all options _in order_. For now they are:

```
$ make
all              All-in-one
tf-init          Initialze the build
plan             Initialze and Plan the build with output log
apply            Build Terraform project with output log
creds            Update the local KUBECONFIG with the new cluster details
xdns             installs metrics server
scale            installs metrics server
observe          Deploy Datadog
graph            Create a visual graph pre-build
opcon            install opcon helm chart
ingress          install ingress
scaletest        Tests HPA scaling
scaleresults     Prints the scale results
scaleclean       Cleans up the junk created from the scale test
apm              Deploys todo demo app with Datadog APM integration
clean            Destroy Terraformed resources and all generated files with output log
reset            clear-off kubeconfig cruft
```

## Terraform


**Initialize**

```
$ make tf-init
terraform init -get=true -backend=true \
	-backend-config="backend.hcl"

Initializing provider plugins...
- Checking for available provider plugins on https://releases.hashicorp.com...
- Downloading plugin for provider "aws" (1.52.0)...

Terraform has been successfully initialized!
...
```

**Plan**

```
$ make plan
terraform plan -no-color \
	-out=/tmp/kubes-stage-or.plan 2>&1 | \
	tee /tmp/tf-kubes-stage-or-plan.out
Refreshing Terraform state in-memory prior to plan...
The refreshed state will be used to calculate this plan, but will not be
persisted to local or remote state storage.
...
------------------------------------------------------------------------

This plan was saved to: /tmp/kubes-stage-or.plan

To perform exactly these actions, run the following command to apply:
    terraform apply "/tmp/kubes-stage-or.plan"
```


**Graph The Build**

Optionally: `make graph`


**Apply**

Assuming all went well - build it.

```
$ make apply
...
terraform apply --auto-approve -no-color \
    -input=false /tmp/kubes-stage-la.plan 2>&1 | tee /tmp/tf-stage-la-plan.out
```

FIXME: This will apply the plan, create a log of the proceedings and store state in the bucket; it takes about 3 minutes. To see the backup:

```
$ gsutil ls -r gs://${TF_VAR_currentProject}
gs://${TF_VAR_currentProject}/terraform/:

gs://${TF_VAR_currentProject}/terraform/state/:
gs://${TF_VAR_currentProject}/terraform/state/default.tfstate  <-- your state!
```


**Access the Kubernetes Dashboard**

`make dashboard`

## Deploy an App

TERM1:

`kubectl create -f zapp/ && watch kubectl get pods`


TERM2:

Get the objects for `service` and `hpa`:

`kubectl get service,hpa`


Expose the Pod (service) listening Port

`kubectl expose deployment hello-kubes --type=LoadBalancer`

Get the services again.


Check any Events

`kubectl describe deployment -l app=hello-kubes | grep -A6 '^Events'`



Contact the Pod

`curl -4 http://PUBLIC_ADDR`


Tear-down

```
kubectl delete service hello-kubes
kubectl delete -f zapp/
```


**Extra Credit**

Delete a `pod` and `node` while watching in TERM1.

**Destroy** the Terraformed configuration

This will destroy all resources in the active state file, sync the state again and remove local stuff; it takes about 7 minutes.

```
$ make clean

terraform destroy --force -auto-approve 2>&1 | \
	tee /tmp/tf-stage-la-destroy.out

Destroy complete!
rm -f "/tmp/kubes-stage-la.plan"
rm -rf .terraform
```

## Afterwards
This is effectively a mirepoix, a solid base to start building _from_.


[EKS Cluster]:https://aws.amazon.com/eks/
[NodeAutoScalingGroup]:https://docs.aws.amazon.com/eks/latest/userguide/launch-workers.html
[expires soon]:https://pythonclock.org/
[aws-iam-authenticator]:https://docs.aws.amazon.com/eks/latest/userguide/configure-kubectl.html
