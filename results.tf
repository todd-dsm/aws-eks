/*
  -----------------------------------------------------------------------------
                                    OUTPUTS
  -----------------------------------------------------------------------------
*/
# snag the worker configmap
output "worker-configmap" {
  value = "${module.kubernetes.config_map_aws_auth}"
}

output "asgMaxNodes" {
  value = "${module.kubernetes.asgMaxNodes}"
}

//# admin-key-pair
//output "master-key" {
//  value = "${module.admin-key-pair.private_key_filename}"
//}