# Definition of the CP Code used for reporting and billing.
resource "akamai_cp_code" "default" {
  name        = local.settings.name
  contract_id = local.settings.akamai.contract
  group_id    = local.settings.akamai.group
  product_id  = local.settings.akamai.property.product
}