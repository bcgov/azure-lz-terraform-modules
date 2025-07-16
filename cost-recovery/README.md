# Azure Cost Recovery Report Generator

This script queries Azure Cost Management API to generate detailed cost recovery reports for Azure subscriptions within a specified management group.

## Features

- Retrieves subscription costs for a specified time period
- Calculates PST, brokerage fees, and total costs
- Groups costs by account coding and expense authority
- Exports results to CSV and formatted Excel files
- Supports querying multiple months of data
- Supports custom date ranges and granularity
- Optionally includes decommissioned management group data
- Excel output is formatted for readability

## Prerequisites

- Python 3.x
- Azure credentials configured (using DefaultAzureCredential)
- Required Python packages (see requirements.txt)
- Access to Azure Management Group with proper permissions

## Usage

Basic usage:

```bash
python cost_recovery.py -m 3
```

### Options

- `-m, --months`: Number of previous months to include (default: 1)
- `--mgmt-group-live`: Name of the live landing zones management group (default: bcgov-managed-lz-live-landing-zones)
- `--mgmt-group-decom`: Name of the decommissioned management group (default: bcgov-managed-lz-decommissioned)
- `--include-decom`: Include the decommissioned management group in the cost recovery report
- `--granularity`: Granularity of the cost report (choices: Daily, Monthly, None; default: Monthly)
- `--output-prefix`: Prefix for output files (default: azure_cost_recovery)
- `--start-date`: Custom start date for the report period (YYYY-MM-DD). Overrides --months if set.
- `--end-date`: Custom end date for the report period (YYYY-MM-DD). Overrides --months if set.

> **Recommendation:** For most use cases, use the default `Monthly` granularity. This provides a clear, summarized view of costs and is suitable for reporting and reconciliation. Daily granularity is only recommended for detailed analysis or troubleshooting specific cost spikes.

### Example

Query the last 3 months for both live and decommissioned management groups, with daily granularity:

```bash
python cost_recovery.py -m 3 --include-decom --granularity Daily
```

Query a custom date range and specify output file prefix:

```bash
python cost_recovery.py --start-date 2024-01-01 --end-date 2024-03-31 --output-prefix my_report
```

## Output

- **Detail CSV**: Subscription-level cost details (e.g., `azure_cost_recovery_detail_2024-01-01_to_2024-03-31.csv`)
- **Summary CSV**: Grouped and calculated summary (e.g., `azure_cost_recovery_report_2024-01-01_to_2024-03-31.csv`)
- **Summary Excel**: Formatted Excel file with summary (e.g., `azure_cost_recovery_report_2024-01-01_to_2024-03-31.xlsx`)

The Excel output includes bold headers, column width adjustments, money formatting, and frozen header row for easier review.

## Notes

- Uses Azure DefaultAzureCredential for authentication
- Monetary calculations use Decimal type for precision
- Default management group: "bcgov-managed-lz-live-landing-zones"
- Tax rates:
  - PST: 7%
  - Brokerage fee: 6%
- You can include decommissioned management group data with `--include-decom`
- For more help, run: `python cost_recovery.py --help`

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
