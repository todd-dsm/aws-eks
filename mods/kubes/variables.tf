/*
  -----------------------------------------------------------------------------
                          Initialize/Declare Variables
                                 PROJECT-LEVEL
  -----------------------------------------------------------------------------
*/
variable "myCo" {
  description = "Expands to Company Name; E.G.: my-company"
  type        = "string"
}

variable "dns_zone" {
  description = "Root DNS Zone for myCo; I.E.: example.tld"
  type        = "string"
}

variable "envBuild" {
  description = "Build Environment; from ENV; E.G.: envBuild=stage"
  type        = "string"
}

variable "region" {
  description = "Deployment Region; from ENV; E.G.: us-west2"
  type        = "string"
}

/*
  -----------------------------------------------------------------------------
                                   KUBERNETES
  -----------------------------------------------------------------------------
*/

variable "project" {
  description = "Project Name: should be set to something like: eks-test"
  type        = "string"
}

variable "cluster_name" {
  description = "Evaluates to deployment_env_state; I.E.: kubes-stage-or"
  type        = "string"
}

variable "officeIPAddr" {
  description = "The IP address of the Current (outbound) Gateway: A.B.C.D/32"
}

variable "host_cidr" {
  description = "CIDR block reserved for networking, from ENV; E.G.: export TF_VAR_host_cidr=10.0.0.0/16"
}

variable "kubeType" {
  description = "Kubernetes type; Managed (EKS; ~1.10) or Unmanaged (Typhoon; current version)"
  type        = "string"
}

variable "kubeNode_type" {
  description = "EKS worker node type, from ENV; E.G.: export TF_VAR_kubeNode_type=typet2.medium"
  type        = "string"
}

variable "kubeNode_count" {
  description = "Initial number of master nodes, from ENV; E.G.: export TF_VAR_kubeNode_count=3"
}
