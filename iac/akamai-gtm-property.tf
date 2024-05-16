# Definition of the GTM property.
resource "akamai_gtm_property" "default" {
  domain                 = akamai_gtm_domain.default.name
  name                   = local.settings.akamai.gtm.label
  type                   = "${local.settings.akamai.gtm.type}-${local.settings.akamai.gtm.mode}"
  score_aggregation_type = local.settings.akamai.gtm.scoreAggregationType
  dynamic_ttl            = local.settings.akamai.gtm.ttl
  handout_limit          = local.settings.akamai.gtm.handout.limit
  handout_mode           = local.settings.akamai.gtm.handout.mode
  backup_cname           = local.settings.akamai.gtm.failover

  # Liveness test definition.
  liveness_test {
    name                 = local.settings.akamai.gtm.livenessTest.label
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

  depends_on = [
    akamai_gtm_domain.default,
    akamai_gtm_datacenter.manager,
    akamai_gtm_datacenter.worker1,
    akamai_gtm_datacenter.worker2
  ]
}

# Point GTM property hostname to an EdgeDNS record.
resource "akamai_dns_record" "default" {
  name       = "${local.settings.akamai.gtm.dns.name}.${local.settings.akamai.gtm.dns.zone}"
  zone       = local.settings.akamai.gtm.dns.zone
  recordtype = "CNAME"
  target     = [ "${akamai_gtm_property.default.name}.${akamai_gtm_domain.default.name}" ]
  ttl        = local.settings.akamai.gtm.dns.ttl
  depends_on = [ akamai_gtm_property.default ]
}