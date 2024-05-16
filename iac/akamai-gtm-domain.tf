# Definition of the GTM domain.
resource "akamai_gtm_domain" "default" {
  name     = "${local.settings.tag}.akadns.net"
  type     = local.settings.akamai.gtm.type
  contract = local.settings.akamai.contract
  group    = local.settings.akamai.group
}