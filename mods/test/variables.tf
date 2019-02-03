/*
  -----------------------------------------------------------------------------
                          Initialize/Declare Variables
                                 MODULE-LEVEL
  -----------------------------------------------------------------------------
*/
variable "dns_zone" {
  description = "Root DNS Zone for myCo; I.E.: example.tld"
  type        = "string"
}
