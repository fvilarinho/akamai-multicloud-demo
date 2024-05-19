# Definition of the property rules (CDN configuration).
data "akamai_property_rules_template" "default" {
  template_file = abspath("akamai-property-rules/main.json")

  # Definition of the Origin Hostname variable.
  variables {
    name  = "originHostname"
    type  = "string"
    value = "${akamai_gtm_property.default.name}.${akamai_gtm_domain.default.name}"
  }

  # Definition of the CP Code variable.
  variables {
    name  = "cpCode"
    type  = "number"
    value = replace(akamai_cp_code.default.id, "cpc_", "")
  }

  depends_on = [
    akamai_gtm_domain.default,
    akamai_gtm_property.default,
    akamai_cp_code.default
  ]
}

# Definition of the property (CDN configuration).
resource "akamai_property" "default" {
  name        = local.settings.name
  contract_id = local.settings.akamai.contract
  group_id    = local.settings.akamai.group
  product_id  = local.settings.akamai.property.product
  rules       = data.akamai_property_rules_template.default.json

  # Definition of all hostnames of the property.
  hostnames {
    cname_from             = "${local.settings.name}.${local.settings.akamai.domain}"
    cname_to               = akamai_edge_hostname.default.edge_hostname
    cert_provisioning_type = "DEFAULT"
  }

  depends_on = [
    data.akamai_property_rules_template.default,
    akamai_edge_hostname.default
  ]
}

# Activates the property (CDN configuration).
resource "akamai_property_activation" "default" {
  property_id                    = akamai_property.default.id
  version                        = akamai_property.default.latest_version
  network                        = var.network
  contact                        = [ local.settings.akamai.email ]
  auto_acknowledge_rule_warnings = true
  depends_on                     = [
    akamai_property.default,
    akamai_dns_record.certificateValidation
  ]
}
