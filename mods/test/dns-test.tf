resource "aws_route53_zone" "test" {
  name = "yo.${var.dns_zone}"
}
