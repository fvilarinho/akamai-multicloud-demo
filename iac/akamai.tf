# Akamai EdgeGrid definition.
provider "akamai" {
  edgerc         = ".edgerc"
  config_section = "default"
}

# Create the Akamai GTM datacenter pointing to AWS.
resource "akamai_gtm_datacenter" "aws" {
  nickname = "aws"
  domain   = var.akamai.balancer.domain
}

# Create the 1o. Akamai GTM datacenter pointing to Linode.
resource "akamai_gtm_datacenter" "linode1" {
  nickname   = "linode1"
  domain     = var.akamai.balancer.domain
}

# Create the 2o. Akamai GTM datacenter pointing to Linode.
resource "akamai_gtm_datacenter" "linode2" {
  nickname   = "linode2"
  domain     = var.akamai.balancer.domain
}

# Create the Akamai GTM datacenter pointing to Azure.
resource "akamai_gtm_datacenter" "azure" {
  nickname = "azure"
  domain   = var.akamai.balancer.domain
}

# Create the Akamai GTM property to balance the DCs traffic.
resource "akamai_gtm_property" "application" {
  name                   = var.akamai.balancer.host
  domain                 = var.akamai.balancer.domain
  type                   = var.akamai.balancer.method
  score_aggregation_type = var.akamai.balancer.aggregation
  handout_limit          = 3
  handout_mode           = var.akamai.balancer.mode
  depends_on             = [ aws_instance.worker, linode_instance.manager, linode_instance.worker, azurerm_linux_virtual_machine.worker, akamai_gtm_datacenter.aws, akamai_gtm_datacenter.linode1, akamai_gtm_datacenter.linode2, akamai_gtm_datacenter.azure ]

  traffic_target {
    datacenter_id = replace(akamai_gtm_datacenter.aws.id, "${var.akamai.balancer.domain}:", "")
    servers       = [ aws_instance.worker.public_ip ]
    weight        = 25
    enabled       = true
  }

  traffic_target {
    datacenter_id = replace(akamai_gtm_datacenter.linode1.id, "${var.akamai.balancer.domain}:", "")
    servers       = [ linode_instance.manager.ip_address ]
    weight        = 25
    enabled       = true
  }

  traffic_target {
    datacenter_id = replace(akamai_gtm_datacenter.linode2.id, "${var.akamai.balancer.domain}:", "")
    servers       = [ linode_instance.worker.ip_address ]
    weight        = 25
    enabled       = true
  }

  traffic_target {
    datacenter_id = replace(akamai_gtm_datacenter.azure.id, "${var.akamai.balancer.domain}:", "")
    servers       = [ azurerm_linux_virtual_machine.worker.public_ip_address ]
    weight        = 25
    enabled       = true
  }

  liveness_test {
    name                 = var.application.label
    test_object_protocol = var.akamai.balancer.healthCheck.protocol
    test_object_port     = var.akamai.balancer.healthCheck.port
    test_object          = var.akamai.balancer.healthCheck.path
    test_interval        = var.akamai.balancer.healthCheck.interval
    test_timeout         = var.akamai.balancer.healthCheck.timeout
    http_error3xx        = var.akamai.balancer.healthCheck.consider_redirects
    http_error4xx        = var.akamai.balancer.healthCheck.consider_not_found
    http_error5xx        = var.akamai.balancer.healthCheck.consider_internal_error
  }
}

# Definition of the Akamai property CPCode.
resource "akamai_cp_code" "application" {
  name        = var.applicatiom.label
  contract_id = var.akamai.contract
  group_id    = var.akamai.group
  product_id  = var.akamai.product
}

# Definition of the Akamai property rule tree.
data "akamai_property_rules_template" "application" {
  template_file = abspath("property-snippets/main.json")

  # Set the Origin Hostname pointing to cluster load balancer.
  variables {
    name  = "originHostname"
    type  = "string"
    value = "${var.akamai.balancer.host}.${var.akamai.balancer.domain}"
  }

  # Set the CPCode.
  variables {
    name  = "cpCode"
    type  = "number"
    value = replace(akamai_cp_code.application.id, "cpc_", "")
  }
}

# Definition of the Akamai property configuration.
resource "akamai_property" "application" {
  name        = var.application.label
  contract_id = var.akamai.contract
  group_id    = var.akamai.group
  product_id  = var.akamai.product
  rules       = data.akamai_property_rules_template.application.json
  depends_on  = [ akamai_cp_code.application, akamai_gtm_property.application ]

  hostnames {
    cname_from             = "${var.application.hostname}.${var.application.domain}"
    cname_to               = var.akamai.property.edgeHostname
    cert_provisioning_type = "CPS_MANAGED"
  }

}

# Definition of the Akamai property activation.
resource "akamai_property_activation" "application" {
  property_id                    = akamai_property.application.id
  version                        = akamai_property.application.latest_version
  contact                        = [ var.application.email ]
  auto_acknowledge_rule_warnings = true
  depends_on                     = [ akamai_property.application ]
}