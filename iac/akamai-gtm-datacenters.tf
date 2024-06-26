# Definition of the GTM datacenters locations.
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
  nickname   = "linode-${local.settings.linode.manager.name}"
  city       = data.linode_region.manager.label
  depends_on = [
    data.linode_region.manager,
    akamai_gtm_domain.default
  ]
}

resource "akamai_gtm_datacenter" "worker1" {
  domain     = akamai_gtm_domain.default.name
  nickname   = "linode-${local.settings.linode.worker.name}"
  city       = data.linode_region.worker.label
  depends_on = [
    data.linode_region.worker,
    akamai_gtm_domain.default
  ]
}

resource "akamai_gtm_datacenter" "worker2" {
  domain     = akamai_gtm_domain.default.name
  nickname   = "aws-${local.settings.aws.worker.name}"
  city       = data.aws_region.worker.description
  depends_on = [
    data.aws_region.worker,
    akamai_gtm_domain.default
  ]
}

resource "akamai_gtm_datacenter" "worker3" {
  domain     = akamai_gtm_domain.default.name
  nickname   = "digitalocean-${local.settings.digitalocean.worker.name}"
  city       = data.digitalocean_region.worker.name
  depends_on = [
    data.digitalocean_region.worker,
    akamai_gtm_domain.default
  ]
}