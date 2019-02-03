/*
  -----------------------------------------------------------------------------
                                PROVIDER CONFIG
  -----------------------------------------------------------------------------
*/
# Create IAM Role for the EKS Cluster
# REF: https://docs.aws.amazon.com/eks/latest/userguide/service_IAM_role.html
resource "aws_iam_role" "kubes-cluster" {
  name = "${var.cluster_name}-cluster"

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

  tags {
    Name = "${var.cluster_name}"
  }
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
