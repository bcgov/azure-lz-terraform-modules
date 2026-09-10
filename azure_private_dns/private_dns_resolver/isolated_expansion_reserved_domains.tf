# Azure ignores '.' wildcard rules for reserved PaaS suffixes
# (windows.net, azure.com, azure.net, windowsazure.us, and the public
# names in https://learn.microsoft.com/en-us/azure/private-link/private-endpoint-dns).
# Isolated expansions therefore need explicit suffix → inbound rules.
# Each privatelink zone used by DINE is listed, plus its public parent
# (privatelink. stripped) and a few aliases that do not follow that pattern.

locals {
  isolated_expansion_privatelink_zones = [
    "privatelink.adf.azure.com",
    "privatelink.afs.azure.net",
    "privatelink.agentsvc.azure-automation.net",
    "privatelink.api.azureml.ms",
    "privatelink.azure-automation.net",
    "privatelink.azure-devices-provisioning.net",
    "privatelink.azure-devices.net",
    "privatelink.azurecr.io",
    "privatelink.azuredatabricks.net",
    "privatelink.azurehdinsight.net",
    "privatelink.azureiotcentral.com",
    "privatelink.azurewebsites.net",
    "privatelink.azconfig.io",
    "privatelink.batch.azure.com",
    "privatelink.blob.core.windows.net",
    "privatelink.canadacentral.azurecontainerapps.io",
    "privatelink.canadacentral.backup.windowsazure.com",
    "privatelink.canadaeast.azurecontainerapps.io",
    "privatelink.canadaeast.backup.windowsazure.com",
    "privatelink.cassandra.cosmos.azure.com",
    "privatelink.cc.backup.windowsazure.com",
    "privatelink.ce.backup.windowsazure.com",
    "privatelink.datafactory.azure.net",
    "privatelink.dev.azuresynapse.net",
    "privatelink.dfs.core.windows.net",
    "privatelink.directline.botframework.com",
    "privatelink.documents.azure.com",
    "privatelink.dp.kubernetesconfiguration.azure.com",
    "privatelink.eventgrid.azure.net",
    "privatelink.fabric.microsoft.com",
    "privatelink.file.core.windows.net",
    "privatelink.grafana.azure.com",
    "privatelink.gremlin.cosmos.azure.com",
    "privatelink.guestconfiguration.azure.com",
    "privatelink.his.arc.azure.com",
    "privatelink.media.azure.net",
    "privatelink.mongo.cosmos.azure.com",
    "privatelink.monitor.azure.com",
    "privatelink.notebooks.azure.net",
    "privatelink.ods.opinsights.azure.com",
    "privatelink.oms.opinsights.azure.com",
    "privatelink.prod.migration.windowsazure.com",
    "privatelink.queue.core.windows.net",
    "privatelink.redis.azure.net",
    "privatelink.redis.cache.windows.net",
    "privatelink.search.windows.net",
    "privatelink.service.signalr.net",
    "privatelink.servicebus.windows.net",
    "privatelink.services.ai.azure.com",
    "privatelink.siterecovery.windowsazure.com",
    "privatelink.sql.azuresynapse.net",
    "privatelink.table.core.windows.net",
    "privatelink.table.cosmos.azure.com",
    "privatelink.vaultcore.azure.net",
    "privatelink.web.core.windows.net",
    "privatelink.webpubsub.azure.com",
    "privatelink.wvd.microsoft.com",
  ]

  isolated_expansion_reserved_public_roots = [
    "azure.com",
    "azure.net",
    "microsoft.com",
    "windows.net",
    "windowsazure.com",
    "windowsazure.us",
  ]

  isolated_expansion_public_aliases = [
    "vault.azure.net",
  ]

  isolated_expansion_additional_domains = [
    for domain in try(var.isolated_expansion_forwarding_ruleset.additional_domains, []) :
    trimsuffix(lower(trimspace(domain)), ".")
    if trimspace(domain) != "" && trimspace(domain) != "."
  ]

  isolated_expansion_explicit_domains = toset(concat(
    local.isolated_expansion_privatelink_zones,
    [for zone in local.isolated_expansion_privatelink_zones : trimprefix(zone, "privatelink.")],
    local.isolated_expansion_reserved_public_roots,
    local.isolated_expansion_public_aliases,
    local.isolated_expansion_additional_domains,
  ))

  isolated_expansion_explicit_rules = {
    for domain in local.isolated_expansion_explicit_domains :
    replace(domain, ".", "-") => "${domain}."
  }
}
