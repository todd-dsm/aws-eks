/*
  -----------------------------------------------------------------------------
                                    OUTPUTS
  -----------------------------------------------------------------------------
*/
# snag the worker configmap
output "worker-configmap" {
  value = "${module.kubernetes.config_map_aws_auth}"
}
