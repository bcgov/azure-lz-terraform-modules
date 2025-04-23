# Azure RBAC Report Generator

This script generates a report of all direct user role assignments within a project set in Azure. It helps identify users who have been directly assigned roles (as opposed to receiving them through group membership) at any level of the project hierarchy.

The report includes both management plane and data plane RBAC assignments by default.

## Prerequisites

- Python 3.7 or higher
- Azure CLI installed and configured
- Appropriate permissions to read role assignments in the target management group and its resources

## Usage

Run the script using `uv run`:

```bash
uv run python main.py --management-group-id <management-group-id> [--output-file <output-file>] [--exclude-data-plane]
```

### Arguments

- `--management-group-id`: (Required) The ID of the management group to analyze
- `--output-file`: (Optional) Path to the output CSV file. Defaults to `role_assignments_report.csv`
- `--exclude-data-plane`: (Optional) Exclude data plane role assignments from the report. By default, all roles are included.

### Examples

Basic usage (all roles):

```bash
uv run python main.py --management-group-id "abc123"
```

Exclude data plane roles:

```bash
uv run python main.py --management-group-id "abc123" --exclude-data-plane
```

## Output

The script generates a CSV file with the following columns:

- User Principal ID
- Principal Type
- Role Name
- Scope
- Assignment Type
- Created On
- Created By

## Notes

- The script requires appropriate Azure permissions to read role assignments
- It may take some time to run for large management groups with many resources
- The script only reports direct user assignments, not assignments through group membership
- All role assignments (including data plane) are included by default, use --exclude-data-plane to show only management plane roles
