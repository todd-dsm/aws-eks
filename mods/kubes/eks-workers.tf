/*
  -----------------------------------------------------------------------------
                               Amazon EKS Workers
  -----------------------------------------------------------------------------
*/
resource "aws_iam_role" "kubes-worker" {
  name = "kubes-stage-node"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}

# Allows: Describe: Instances, RouteTables, SecurityGroups, Subnets, Volumes,
# VolumesModifications, VPCs and Clusters
resource "aws_iam_role_policy_attachment" "kubes-node-AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = "${aws_iam_role.kubes-worker.name}"
}

# This policy provides the Amazon VPC CNI Plugin (amazon-vpc-cni-k8s) the permissions it requires to modify the
# IP address configuration on your EKS worker nodes
resource "aws_iam_role_policy_attachment" "kubes-node-AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = "${aws_iam_role.kubes-worker.name}"
}

# Allows Workers to pull images from the Elastic Container Registry
resource "aws_iam_role_policy_attachment" "kubes-node-AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = "${aws_iam_role.kubes-worker.name}"
}

resource "aws_iam_instance_profile" "kubes-node" {
  name = "kubes-stage-node-profile"
  role = "${aws_iam_role.kubes-worker.name}"
}

/*
  -----------------------------------------------------------------------------
                          Worker Node AutoScaling Group
  -----------------------------------------------------------------------------
*/
resource "aws_autoscaling_group" "kubes" {
  desired_capacity     = "${var.kubeNode_count}"
  launch_configuration = "${aws_launch_configuration.kubes.id}"
  max_size             = 5
  min_size             = "${var.kubeNode_count}"
  name                 = "eks-kubes"
  vpc_zone_identifier  = ["${aws_subnet.kubes.*.id}"]

  tag {
    key                 = "Name"
    value               = "kubes-stage-node"
    propagate_at_launch = true
  }

  tag {
    key                 = "kubernetes.io/cluster/${var.cluster_name}"
    value               = "owned"
    propagate_at_launch = true
  }
}

/*
  -----------------------------------------------------------------------------
                         AutoScaling Group Launch Config
  -----------------------------------------------------------------------------
*/
locals {
  kubes-node-userdata = <<USERDATA
#!/bin/bash
set -o xtrace
/etc/eks/bootstrap.sh --apiserver-endpoint '${aws_eks_cluster.kubes.endpoint}' --b64-cluster-ca '${aws_eks_cluster.kubes.certificate_authority.0.data}' '${var.cluster_name}'
USERDATA
}

resource "aws_launch_configuration" "kubes" {
  associate_public_ip_address = true
  iam_instance_profile        = "${aws_iam_instance_profile.kubes-node.name}"
  image_id                    = "${data.aws_ami.eks-worker.id}"
  instance_type               = "${var.kubeNode_type}"
  key_name                    = "master.pem"
  name_prefix                 = "eks-kubes"
  security_groups             = ["${aws_security_group.kubes-node.id}"]
  user_data_base64            = "${base64encode(local.kubes-node-userdata)}"

  lifecycle {
    create_before_destroy = true
  }
}

/*
  -----------------------------------------------------------------------------
                            Join Workers to Cluster
  -----------------------------------------------------------------------------
*/

locals {
  config_map_aws_auth = <<CONFIGMAPAWSAUTH
apiVersion: v1
kind: ConfigMap
metadata:
  name: aws-auth
  namespace: kube-system
data:
  mapRoles: |
    - rolearn: ${aws_iam_role.kubes-worker.arn}
      username: system:node:{{EC2PrivateDNSName}}
      groups:
        - system:bootstrappers
        - system:nodes
CONFIGMAPAWSAUTH
}

output "config_map_aws_auth" {
  value = "${local.config_map_aws_auth}"
}

/*
  -----------------------------------------------------------------------------
                             AMI Filter for Workers
  -----------------------------------------------------------------------------
*/
data "aws_ami" "eks-worker" {
  filter {
    name   = "name"
    values = ["amazon-eks-node-1.11-*"]
  }

  most_recent = true
  owners      = ["602401143452"] # Amazon EKS AMI Account ID
}
