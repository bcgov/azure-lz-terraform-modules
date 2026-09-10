# Private Link Private DNS Zones

List Private Link private DNS zones deployed in the connectivity subscription.

## Prerequisites

- Python 3.9 or higher
- Azure CLI installed
- Logged in with `az login`
- Reader access to the connectivity subscription

## Usage

```bash
python3 scripts/private-dns-zones/list_privatelink_dns_zones.py \
  --subscription-id <connectivity-subscription-id>
```

You can also set the subscription once:

```bash
export AZURE_CONNECTIVITY_SUBSCRIPTION_ID=<connectivity-subscription-id>
python3 scripts/private-dns-zones/list_privatelink_dns_zones.py
```

Filter to the landing zone DNS resource group:

```bash
python3 scripts/private-dns-zones/list_privatelink_dns_zones.py \
  --subscription-id <connectivity-subscription-id> \
  --resource-group <root-id>-dns
```

Write CSV:

```bash
python3 scripts/private-dns-zones/list_privatelink_dns_zones.py \
  --subscription-id <connectivity-subscription-id> \
  --output csv \
  --output-file privatelink_dns_zones.csv
```

Print only raw domain names:

```bash
python3 scripts/private-dns-zones/list_privatelink_dns_zones.py \
  --subscription-id <connectivity-subscription-id> \
  --domains-only
```

## Output

By default the script prints a text table with:

- Private DNS zone name
- Resource group
- Resource ID

Use `--output json` or `--output csv` for machine-readable output.
Use `--domains-only` to print one private DNS zone name per line with no header or extra columns.
