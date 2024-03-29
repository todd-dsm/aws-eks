/*
  -----------------------------------------------------------------------------
                              AWS Security Groups
                                 EKS: Cluster
    This security group controls networking access to the Kubernetes masters.
  -----------------------------------------------------------------------------
*/
### EKS Cluster: allow all outbound traffic
resource "aws_security_group" "kubes-cluster" {
  name        = "${var.cluster_name}-cluster"
  description = "Cluster communication with worker nodes"
  vpc_id      = "${aws_vpc.kubes.id}"

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Name = "${var.cluster_name}"
  }
}

# Cluster access from workers
resource "aws_security_group_rule" "kubes-cluster-ingress-node-https" {
  description              = "Allow pods to communicate with the cluster API Server"
  from_port                = 0
  protocol                 = "-1"
  security_group_id        = "${aws_security_group.kubes-cluster.id}"
  source_security_group_id = "${aws_security_group.kubes-node.id}"
  to_port                  = 65535
  type                     = "ingress"
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
  name        = "${var.cluster_name}-node"
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
     "Name", "${var.cluster_name}",
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
  from_port                = 0
  protocol                 = "-1"
  security_group_id        = "${aws_security_group.kubes-node.id}"
  source_security_group_id = "${aws_security_group.kubes-cluster.id}"
  to_port                  = 65535
  type                     = "ingress"
}

/*
  -----------------------------------------------------------------------------
                                 OFFICE COMMS
  Access worker Node Access from the Office
    This is a temporary measure until the nodes are tuned and we've gotten
    everything off of them, metrics, logs, etc.
    After that point, the below lines can be commented.
  -----------------------------------------------------------------------------
*/
resource "aws_security_group_rule" "kubes-node-office-access" {
  description       = "Allow pods to communicate with the cluster API Server"
  from_port         = 22
  protocol          = "tcp"
  security_group_id = "${aws_security_group.kubes-node.id}"
  cidr_blocks       = ["${var.officeIPAddr}"]
  to_port           = 22
  type              = "ingress"
}
