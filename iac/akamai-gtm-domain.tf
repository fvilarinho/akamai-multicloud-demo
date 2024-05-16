# Definition of the GTM domain.
resource "akamai_gtm_domain" "default" {
  contract = local.settings.akamai.contract
  group    = local.settings.akamai.group
  name     = "${local.settings.tag}.akadns.net"
  type     = local.settings.akamai.gtm.type
}