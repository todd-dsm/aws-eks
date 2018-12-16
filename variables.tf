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
                                 STATE SECURITY
  -----------------------------------------------------------------------------
*/
variable "kms_name" {
  default = "alias/aws/s3"
}

variable "kms_key" {
  default = "8828d123-a3cf-42de-ab8a-628cf9d839d3"
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
  description = "Is the IP address of the Current (outbound) Gateway: A.B.C.D/32"
}

variable "host_cidr" {
  description = "CIDR block reserved for networking, from ENV; E.G.: export TF_VAR_host_cidr=10.0.16.0/20"
}

//variable "cluster_name" {
//  description = "Display name in GKE and kubectl; from ENV; E.G.: TF_VAR_cluster_name=kubes-stage-la"
//}
//
//variable "kubeMaster_type" {
//  description = "GKE master machine type; from ENV; E.G.: export TF_VAR_kubeMaster_type=n1-standard-1"
//}
//
//variable "kubeMaster_count" {
//  description = "Initial number of master nodes, from ENV; E.G.: export TF_VAR_kubeMaster_count=3"
//}

variable "kubeNode_type" {
  description = "EKS worker node type, from ENV; E.G.: export TF_VAR_kubeNode_type=typet2.medium"
  type        = "string"
}

variable "kubeNode_count" {
  description = "Initial number of master nodes, from ENV; E.G.: export TF_VAR_kubeNode_count=3"
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

