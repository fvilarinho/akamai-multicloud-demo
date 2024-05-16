# Definition of the GTM datacenters.
resource "akamai_gtm_datacenter" "manager" {
  domain     = akamai_gtm_domain.default.name
  nickname   = local.settings.linode.manager.label
  city       = local.settings.linode.region
  depends_on = [ akamai_gtm_domain.default ]
}

resource "akamai_gtm_datacenter" "worker1" {
  domain     = akamai_gtm_domain.default.name
  nickname   = local.settings.linode.worker.label
  city       = local.settings.linode.region
  depends_on = [ akamai_gtm_domain.default ]
}

resource "akamai_gtm_datacenter" "worker2" {
  domain     = akamai_gtm_domain.default.name
  nickname   = local.settings.aws.worker.label
  city       = local.settings.aws.region
  depends_on = [ akamai_gtm_domain.default ]
}
