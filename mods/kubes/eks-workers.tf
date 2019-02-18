/*
  -----------------------------------------------------------------------------
                               Amazon EKS Workers
  -----------------------------------------------------------------------------
*/
# Empulate GCP Node Pools: https://goo.gl/rgvKZ6
# Apps will require nodes of a type (https://goo.gl/59jXy). We will configure
# an app-specific node, then label it so containers are scheduled properly.
# This will ensure pod scheduling on nodes with the right resources.
variable "myApp" {
  description = "app for nodes"
  default     = "opcon"
}

variable "nodeLabel" {
  description = "nodeLabel determined by app reqs; used for Kubernetes node label."
  default     = "--node-labels=app=opcon"
}

variable "kubeNode_max" {
  description = "autoscaler max node count"
  default     = "5"
}

/*
  -----------------------------------------------------------------------------
                          Worker Node AutoScaling Group
  -----------------------------------------------------------------------------
*/
resource "aws_autoscaling_group" "kubes" {
  desired_capacity     = "${var.minDistSize}"
  min_size             = "${var.minDistSize}"
  max_size             = "${var.kubeNode_max}"
  vpc_zone_identifier  = ["${aws_subnet.kubes.*.id}"]
  name                 = "${var.cluster_name}"
  launch_configuration = "${aws_launch_configuration.kubes.id}"

  tag {
    key                 = "Name"
    value               = "kubes-node-${var.myApp}"
    propagate_at_launch = true
  }

  tag {
    key                 = "env"
    value               = "${var.envBuild}"
    propagate_at_launch = true
  }

  tag {
    key                 = "app"
    value               = "${var.myApp}"
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
# see options: https://github.com/awslabs/amazon-eks-ami/blob/master/files/bootstrap.sh
locals {
  kubes-node-userdata = <<USERDATA
#!/bin/bash
set -o xtrace
/etc/eks/bootstrap.sh \
  --apiserver-endpoint '${aws_eks_cluster.kubes.endpoint}' \
  --b64-cluster-ca '${aws_eks_cluster.kubes.certificate_authority.0.data}' '${var.cluster_name}' \
  --kubelet-extra-args '${var.nodeLabel}'
USERDATA
}

# aws_launch_configuration cannot be tagged
resource "aws_launch_configuration" "kubes" {
  associate_public_ip_address = true
  iam_instance_profile        = "${aws_iam_instance_profile.kubes-node.name}"
  key_name                    = "${var.builder}"
  image_id                    = "${data.aws_ami.eks-worker.id}"
  instance_type               = "${var.kubeNode_type}"
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
  mapUsers: |
    - userarn: arn:aws:iam::${var.aws_acct_no}:user/thomast23
      username: thomast23
      groups:
        - system:masters
    - userarn: arn:aws:iam::${var.aws_acct_no}:user/leij
      username: leij
      groups:
        - system:masters
    - userarn: arn:aws:iam::${var.aws_acct_no}:user/vanderhoofm
      username: vanderhoofm
      groups:
        - system:masters
CONFIGMAPAWSAUTH
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

/*
  -----------------------------------------------------------------------------
                                    OUTPUTS
  -----------------------------------------------------------------------------
*/
output "config_map_aws_auth" {
  value = "${local.config_map_aws_auth}"
}

output "asgMaxNodes" {
  value = "${aws_autoscaling_group.kubes.max_size}"
}

/*
  -----------------------------------------------------------------------------
                        Worker IAM Policies ExternalDNS
  -----------------------------------------------------------------------------
*/
data "aws_route53_zone" "gnoe_zone" {
  name         = "${var.dns_zone}."
  private_zone = false
}


/*
  -----------------------------------------------------------------------------
                               Worker IAM Roles
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

# ------------------------------ auto-scaling ---------------------------------
# Access to AutoScaling
resource "aws_iam_role_policy_attachment" "kubes-node-AutoScalingFullAccess" {
  policy_arn = "arn:aws:iam::aws:policy/AutoScalingFullAccess"
  role       = "${aws_iam_role.kubes-worker.name}"
}

# ------------------------------ node-profile ---------------------------------
resource "aws_iam_instance_profile" "kubes-node" {
  name = "kubes-stage-node-profile"
  role = "${aws_iam_role.kubes-worker.name}"
}

/*
  -----------------------------------------------------------------------------
                              Custom Policies
  -----------------------------------------------------------------------------
*/

# ------------------------------- ECR Access  ---------------------------------
# Allows Workers to pull images from the Elastic Container Registry
resource "aws_iam_role_policy_attachment" "kubes-node-AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = "${aws_iam_role.kubes-worker.name}"
}


# ------------------------------ external-dns ---------------------------------
resource "aws_iam_role_policy_attachment" "kubes-node-xdns-policy" {
  policy_arn = "${aws_iam_policy.external-dns-policy.arn}"
  role       = "${aws_iam_role.kubes-worker.name}"
}

resource "aws_iam_policy" "external-dns-policy" {
  name = "kubes-external-dns-policy"
  path = "/"
  description = "Allows EKS nodes to modify Route53 to support ExternalDNS."

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "route53:ListHostedZones",
                "route53:ListResourceRecordSets"
            ],
            "Resource": ["*"]
        },
        {
            "Effect": "Allow",
            "Action": [
                "route53:ChangeResourceRecordSets"
            ],
            "Resource": ["*"]
        }
    ]
}
EOF
}

# Which zone did we find
output "hosted_zone" {
  value = "${data.aws_route53_zone.gnoe_zone.id}"
}