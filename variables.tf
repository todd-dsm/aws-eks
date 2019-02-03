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

///*
//  -----------------------------------------------------------------------------
//                                 STATE SECURITY
//  -----------------------------------------------------------------------------
//*/
//variable "kms_name" {
//  default = "alias/aws/s3"
//}
//
//variable "kms_key" {
//  description = "AWS-provided s3 encryption key, for now."
//  default = "xoxoxoxo-xoxo-xoxo-xoxo-xoxoxoxoxoxo"
//}

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

variable "builder" {
  description = "Evaluates to $USER; there must be key-piar (with the same name) in EC2 prior to apply."
}

variable "officeIPAddr" {
  description = "The IP address of the Current (outbound) Gateway: individual A.B.C.D/32 or block A.B.C.D/29"
  type        = "string"
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

variable "minDistSize" {
  description = "ENV Integer; initial count of distributed subnets, workers, etc; E.G.: export TF_VAR_minDistSize=3"
}

//variable "kubes_log_service" {
//  type    = "string"
//  default = "logging.googleapis.com/kubernetes"
//}
//
//variable "kubes_monitor_service" {
//  type    = "string"
//  default = "monitoring.googleapis.com/kubernetes"
//}

