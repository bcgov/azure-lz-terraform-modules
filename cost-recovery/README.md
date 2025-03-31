# Azure Cost Recovery Report Generator

This script queries Azure Cost Management API to generate detailed cost recovery reports for Azure subscriptions within a specified management group.

## Features

- Retrieves subscription costs for a specified time period
- Calculates PST, brokerage fees, and total costs
- Groups costs by account coding and expense authority
- Exports results to CSV and formatted Excel files
- Supports querying multiple months of data

## Prerequisites

- Python 3.x
- Azure credentials configured (using DefaultAzureCredential)
- Required Python packages (see requirements.txt)
- Access to Azure Management Group with proper permissions

## Usage

Basic usage:

```bash
python generate_cost_report.py -m 3
```

### Options

- `-m, --months`: Number of previous months to include (default: 1)

## Notes

- Uses Azure DefaultAzureCredential for authentication
- Monetary calculations use Decimal type for precision
- Default management group: "bcgov-managed-lz-live-landing-zones"
- Tax rates:
  - PST: 7%
  - Brokerage fee: 6%

<!-- BEGIN_TF_DOCS -->

## Requirements

No requirements.

## Providers

No providers.

## Modules

No modules.

## Resources

No resources.

## Inputs

No inputs.

## Outputs

No outputs.

<!-- END_TF_DOCS -->
