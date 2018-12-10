/*
  -----------------------------------------------------------------------------
                             REMOTE STATE STORAGE
  -----------------------------------------------------------------------------
*/
resource "aws_s3_bucket" "terraform-state-storage" {
  bucket = "myco.eks-test"

  versioning {
    enabled = true
  }

//  lifecycle {
//    prevent_destroy = true
//  }

  tags {
    Name = "S3 Remote TF State Store stage eks-test"
  }
}

resource "aws_s3_bucket_object" "examplebucket_object" {
  key                    = "state"
  source                 = ""
  bucket                 = "${aws_s3_bucket.terraform-state-storage.id}"
  server_side_encryption = "aws:kms"
}
