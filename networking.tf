/*
  -----------------------------------------------------------------------------
                                  DISCOVERY
  -----------------------------------------------------------------------------
*/
# Discover Zones
data "aws_availability_zones" "available" {}

/*
  -----------------------------------------------------------------------------
                                  NETWORKING
  -----------------------------------------------------------------------------
*/
# THE VPC
resource "aws_vpc" "kubes" {
  cidr_block = "${var.host_cidr}"

  tags = "${
    map(
     "Name", "${var.cluster_name}",
     "kubernetes.io/cluster/${var.cluster_name}", "shared",
    )
  }"
}

# Create Subnetes within the VPC
resource "aws_subnet" "kubes" {
  count = 3

  availability_zone = "${data.aws_availability_zones.available.names[count.index]}"
  cidr_block        = "10.0.${count.index}.0/24"
  vpc_id            = "${aws_vpc.kubes.id}"

  tags = "${
    map(
     "Name", "${var.cluster_name}",
     "kubernetes.io/cluster/${var.cluster_name}", "shared",)
  }"
}

resource "aws_internet_gateway" "kubes" {
  vpc_id = "${aws_vpc.kubes.id}"

  tags {
    Name = "${var.cluster_name}"
  }
}

# Create a Route
resource "aws_route_table" "kubes" {
  vpc_id = "${aws_vpc.kubes.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.kubes.id}"
  }

  tags {
    Name = "${var.cluster_name}"
  }
}

# Associate all subnets with the route
resource "aws_route_table_association" "kubes" {
  count          = "${aws_subnet.kubes.count}"
  subnet_id      = "${aws_subnet.kubes.*.id[count.index]}"
  route_table_id = "${aws_route_table.kubes.id}"
}
