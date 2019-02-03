/*
  -----------------------------------------------------------------------------
                                PROVIDER CONFIG
  -----------------------------------------------------------------------------
*/
# REF: Provider Configuration: https://www.terraform.io/docs/configuration/providers.html

provider "aws" {
  region = "${var.region}"

  # any non-beta version >= 1.51
  version = "~> 1.51" # Latest as of 2018/12/09
}

terraform {
  backend "s3" {}
}
