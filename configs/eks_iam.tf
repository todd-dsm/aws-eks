/*
  -----------------------------------------------------------------------------
                                PROVIDER CONFIG
  -----------------------------------------------------------------------------
*/
# Create IAM Role for the EKS Cluster
resource "aws_iam_role" "kubes-cluster" {
  name = "terraform-eks-kubes-cluster"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "eks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}

### Attach Policies to the above Role
# Cluster Policy
resource "aws_iam_role_policy_attachment" "kubes-cluster-AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = "${aws_iam_role.kubes-cluster.name}"
}

# Service Policy
resource "aws_iam_role_policy_attachment" "kubes-cluster-AmazonEKSServicePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSServicePolicy"
  role       = "${aws_iam_role.kubes-cluster.name}"
}
