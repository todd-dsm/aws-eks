/*
  -----------------------------------------------------------------------------
                              AWS Security Groups
                                 EKS: Cluster
  -----------------------------------------------------------------------------
*/
### EKS Cluster: allow all outbound traffic
resource "aws_security_group" "kubes-cluster" {
  name        = "terraform-eks-kubes-cluster"
  description = "Cluster communication with worker nodes"
  vpc_id      = "${aws_vpc.kubes.id}"

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Name = "kubes-stage"
  }
}

# Allow inbound traffic from the Office Gateway
resource "aws_security_group_rule" "kubes-cluster-ingress-workstation-https" {
  cidr_blocks       = ["${var.officeIPAddr}"]
  description       = "Allow workstation to communicate with the cluster API Server"
  from_port         = 443
  protocol          = "tcp"
  security_group_id = "${aws_security_group.kubes-cluster.id}"
  to_port           = 443
  type              = "ingress"
}

/*
  -----------------------------------------------------------------------------
                              AWS Security Groups
                                 EKS: Workers
  -----------------------------------------------------------------------------
*/
# This security group controls networking access to the Kubernetes worker nodes.
resource "aws_security_group" "kubes-node" {
  name        = "terraform-eks-kubes-node"
  description = "Security group for all nodes in the cluster"
  vpc_id      = "${aws_vpc.kubes.id}"

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = "${
    map(
     "Name", "terraform-eks-kubes-node",
     "kubernetes.io/cluster/${var.cluster_name}", "owned",
    )
  }"
}

resource "aws_security_group_rule" "kubes-node-ingress-self" {
  description              = "Allow node to communicate with each other"
  from_port                = 0
  protocol                 = "-1"
  security_group_id        = "${aws_security_group.kubes-node.id}"
  source_security_group_id = "${aws_security_group.kubes-node.id}"
  to_port                  = 65535
  type                     = "ingress"
}

resource "aws_security_group_rule" "kubes-node-ingress-cluster" {
  description              = "Allow worker Kubelets and pods to receive communication from the cluster control plane"
  from_port                = 1025
  protocol                 = "tcp"
  security_group_id        = "${aws_security_group.kubes-node.id}"
  source_security_group_id = "${aws_security_group.kubes-cluster.id}"
  to_port                  = 65535
  type                     = "ingress"
}

# Worker Node Access to EKS Master Cluster
resource "aws_security_group_rule" "kubes-cluster-ingress-node-https" {
  description              = "Allow pods to communicate with the cluster API Server"
  from_port                = 443
  protocol                 = "tcp"
  security_group_id        = "${aws_security_group.kubes-cluster.id}"
  source_security_group_id = "${aws_security_group.kubes-node.id}"
  to_port                  = 443
  type                     = "ingress"
}
