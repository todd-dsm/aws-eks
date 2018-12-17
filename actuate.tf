/*
  -----------------------------------------------------------------------------
                               Actuate the Build
  -----------------------------------------------------------------------------
*/

module "kubernetes" {
  source         = "./mods/kubes"
  envBuild       = "${var.envBuild}"
  cluster_name   = "${var.cluster_name}"
  kubeType       = "${var.kubeType}"
  kubeNode_type  = "${var.kubeNode_type}"
  kubeNode_count = "${var.kubeNode_count}"
  myCo           = "${var.myCo}"
  project        = "${var.project}"
  region         = "${var.region}"
  dns_zone       = "${var.dns_zone}"
  host_cidr      = "${var.host_cidr}"
  officeIPAddr   = "${var.host_cidr}"
}
