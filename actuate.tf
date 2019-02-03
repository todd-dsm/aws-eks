/*
  -----------------------------------------------------------------------------
                               Actuate the Build
  -----------------------------------------------------------------------------
*/
# cluster: testing
module "kubernetes" {
  source        = "./mods/kubes"
  envBuild      = "${var.envBuild}"
  cluster_name  = "${var.cluster_name}"
  kubeType      = "${var.kubeType}"
  kubeNode_type = "${var.kubeNode_type}"
  minDistSize   = "${var.minDistSize}"
  myCo          = "${var.myCo}"
  project       = "${var.project}"
  region        = "${var.region}"
  dns_zone      = "${var.dns_zone}"
  host_cidr     = "${var.host_cidr}"
  officeIPAddr  = "${var.officeIPAddr}"
  builder       = "${var.builder}"
}

# ephemeral encryption keys
//module "admin-key-pair" {
//  source                = "github.com/cloudposse/terraform-aws-key-pair.git"
//  version               = "0.3.1"
//  namespace             = "${var.myCo}"
//  stage                 = "${var.envBuild}"
//  name                  = "master"
//  ssh_public_key_path   = "./secrets"
//  generate_ssh_key      = "true"
//  private_key_extension = ".pem"
//  public_key_extension  = ".pub"
//  chmod_command         = "chmod 400 %v"
//}

# ephemeral state backend
//module "terraform_state_backend" {
//  source     = "github.com/cloudposse/terraform-aws-tfstate-backend.git"
//  version    = "0.3.1"
//  namespace  = "${var.myCo}"
//  attributes = ["state"]
//  region     = "${var.region}"
//}


# test module
//module "tester" {
//  source   = "./mods/test"
//  dns_zone = "${var.dns_zone}"
//}

