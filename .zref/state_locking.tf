/*
  -----------------------------------------------------------------------------
                      BACKEND STATE-LOCKING CONFIGURATION
  -----------------------------------------------------------------------------
*/
# create a dynamodb table for locking the state file
resource "aws_dynamodb_table" "tf-state-lock-table" {
  name           = "terraform-state-lock-dynamo"
  hash_key       = "LockID"
  read_capacity  = 20
  write_capacity = 20

  attribute {
    name = "LockID"
    type = "S"
  }

  //  lifecycle {
  //    prevent_destroy = true
  //  }

  tags {
    Name = "DynamoDB Terraform State Lock Table"
  }
}
