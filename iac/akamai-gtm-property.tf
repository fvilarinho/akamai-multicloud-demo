# Definition of the GTM property.
resource "akamai_gtm_property" "default" {
  name                   = "gtm"
  domain                 = akamai_gtm_domain.default.name
  type                   = "${local.settings.akamai.gtm.type}-${local.settings.akamai.gtm.mode}"
  score_aggregation_type = local.settings.akamai.gtm.scoreAggregationType
  dynamic_ttl            = local.settings.akamai.gtm.ttl
  handout_limit          = local.settings.akamai.gtm.handout.limit
  handout_mode           = local.settings.akamai.gtm.handout.mode

  # Liveness test definition.
  liveness_test {
    name                 = local.settings.akamai.gtm.livenessTest.name
    test_interval        = local.settings.akamai.gtm.livenessTest.interval
    test_object_protocol = local.settings.akamai.gtm.livenessTest.protocol
    test_timeout         = local.settings.akamai.gtm.livenessTest.timeout
  }

  # Traffic targets definition.
  traffic_target {
    datacenter_id = akamai_gtm_datacenter.manager.datacenter_id
    weight        = local.settings.akamai.gtm.weights[0]
    servers       = [ linode_instance.manager.ip_address ]
    enabled       = true
  }

  traffic_target {
    datacenter_id = akamai_gtm_datacenter.worker1.datacenter_id
    weight        = local.settings.akamai.gtm.weights[1]
    servers       = [ linode_instance.worker.ip_address ]
    enabled       = true
  }

  traffic_target {
    datacenter_id = akamai_gtm_datacenter.worker2.datacenter_id
    weight        = local.settings.akamai.gtm.weights[2]
    servers       = [ aws_instance.worker.public_ip ]
    enabled       = true
  }

  traffic_target {
    datacenter_id = akamai_gtm_datacenter.worker3.datacenter_id
    weight        = local.settings.akamai.gtm.weights[3]
    servers       = [ digitalocean_droplet.worker.ipv4_address ]
    enabled       = true
  }

  depends_on = [
    akamai_gtm_domain.default,
    akamai_gtm_datacenter.manager,
    akamai_gtm_datacenter.worker1,
    akamai_gtm_datacenter.worker2,
    akamai_gtm_datacenter.worker3
  ]
}