# Definition of the GTM datacenters.
data "linode_region" "manager" {
  id = local.settings.linode.manager.region
}

data "linode_region" "worker" {
  id = local.settings.linode.worker.region
}

data "aws_region" "worker" {
}

data "digitalocean_region" "worker" {
  slug = local.settings.digitalocean.worker.region
}

resource "akamai_gtm_datacenter" "manager" {
  domain     = akamai_gtm_domain.default.name
  nickname   = "linode-${local.settings.linode.manager.label}"
  city       = data.linode_region.manager.label
  depends_on = [ akamai_gtm_domain.default ]
}

resource "akamai_gtm_datacenter" "worker1" {
  domain     = akamai_gtm_domain.default.name
  nickname   = "linode-${local.settings.linode.worker.label}"
  city       = data.linode_region.worker.label
  depends_on = [ akamai_gtm_domain.default ]
}

resource "akamai_gtm_datacenter" "worker2" {
  domain     = akamai_gtm_domain.default.name
  nickname   = "aws-${local.settings.aws.worker.label}"
  city       = data.aws_region.worker.description
  depends_on = [ akamai_gtm_domain.default ]
}

resource "akamai_gtm_datacenter" "worker3" {
  domain     = akamai_gtm_domain.default.name
  nickname   = "digitalocean-${local.settings.digitalocean.worker.label}"
  city       = data.digitalocean_region.worker.name
  depends_on = [ akamai_gtm_domain.default ]
}