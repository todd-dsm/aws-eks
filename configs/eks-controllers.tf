/*
  -----------------------------------------------------------------------------
                               Amazon EKS Cluster
                Amazon Elastic Container Service for Kubernetes
              AWS manages the Controllers Customer manages workers
  -----------------------------------------------------------------------------
*/
resource "aws_eks_cluster" "kubes" {
  name     = "${var.cluster_name}"
  role_arn = "${aws_iam_role.kubes-cluster.arn}"

  vpc_config {
    security_group_ids = ["${aws_security_group.kubes-cluster.id}"]
    subnet_ids         = ["${aws_subnet.kubes.*.id}"]
  }

  depends_on = [
    "aws_iam_role_policy_attachment.kubes-cluster-AmazonEKSClusterPolicy",
    "aws_iam_role_policy_attachment.kubes-cluster-AmazonEKSServicePolicy",
  ]
}
