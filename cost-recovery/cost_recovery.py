from datetime import datetime
from decimal import ROUND_HALF_UP, Decimal

import pandas as pd
from azure.identity import DefaultAzureCredential
from azure.mgmt.costmanagement import CostManagementClient
from azure.mgmt.resource import ResourceManagementClient
from dateutil.relativedelta import relativedelta


# ---------------------------------------------------------------------------
# Cost Recovery Report
#
# Queries Azure Cost Management for actual subscription costs, tags each
# subscription with its Account Coding / Expense Authority, and rolls up
# costs into a chargeback summary with PST and brokerage fees applied.
# ---------------------------------------------------------------------------


def get_subscription_costs(
    management_group_id: str,
    start_date: str,
    end_date: str,
    granularity: str = "Monthly",
):
    """
    Query Azure Cost Management for subscription costs within a management group.
    """
    try:
        # Initialize credentials and client
        credential = DefaultAzureCredential()
        cost_client = CostManagementClient(credential)
        resource_client = ResourceManagementClient(credential, "c1351539-1deb-44e8-b9b9-10f0a608fda4")

        # Build query definition for costs
        query = {
            "type": "ActualCost",
            "timeframe": "Custom",
            "timePeriod": {
                "from": f"{start_date}T00:00:00+00:00",
                "to": f"{end_date}T23:59:59+00:00",
            },
            "dataset": {
                "granularity": granularity,
                "aggregation": {"totalCost": {"name": "Cost", "function": "Sum"}},
                "grouping": [
                    {"type": "Dimension", "name": "SubscriptionId"},
                    {"type": "Dimension", "name": "SubscriptionName"},
                ],
            },
        }

        # Execute query with management group scope
        scope = (
            f"/providers/Microsoft.Management/managementGroups/{management_group_id}"
        )
        print("\nExecuting query with parameters:")
        print(f"Scope: {scope}")
        print(f"Query parameters: {query}")

        try:
            results = cost_client.query.usage(scope=scope, parameters=query)
            print("\nQuery executed successfully")
        except Exception as api_error:
            print("\nAPI Error Details:")
            print(f"Error type: {type(api_error).__name__}")
            if hasattr(api_error, "response"):
                print(f"Response status: {api_error.response.status_code}")
                print(f"Response headers: {api_error.response.headers}")
                print(f"Response content: {api_error.response.text}")
            raise

        # Process results into DataFrame
        cost_data = []
        for row in results.rows:
            # Print row data for debugging
            print(f"Debug - Row data: {row}")
            sub_name = row[3].split("(")[0].strip()
            license_plate = sub_name.split("-")[0].strip() if "-" in sub_name else sub_name
            cost_data.append(
                {
                    "Cost": round(
                        float(row[0]), 2
                    ),  # Cost is first, rounded to 2 decimals
                    "Date": row[1],  # Date is second
                    "SubscriptionId": row[2],  # ID is third
                    "SubscriptionName": sub_name,  # Name is fourth
                    "LicensePlate": license_plate,
                    "Currency": row[4],  # Currency is last
                }
            )

        df = pd.DataFrame(cost_data)

        # Get subscription tags
        print("\nFetching subscription tags...")
        for index, row in df.iterrows():
            try:
                sub_scope=f"/subscriptions/{row['SubscriptionId']}"
                tag_details = resource_client.tags.get_at_scope(sub_scope)
                tags = (tag_details.properties.tags
                        if tag_details and tag_details.properties
                        else {}
                )
                df.at[index, "AccountCoding"] = (
                    tags.get("account_coding", "Untagged")
                    if tags
                    else "Untagged"
                )
                df.at[index, "ExpenseAuthority"] = (
                    tags.get("expense_authority", "Untagged")
                    if tags
                    else "Untagged"
                )
            except Exception as e:
                print(
                    f"Warning: Could not fetch tags for subscription {row['SubscriptionId']}: {str(e)}"
                )
                df.at[index, "AccountCoding"] = "Untagged"
                df.at[index, "ExpenseAuthority"] = "Untagged"

        # Create summary by account coding with tax calculations
        summary_df = (
            df.groupby(["AccountCoding", "ExpenseAuthority"])
            .agg(
                {
                    "Cost": lambda x: round(sum(x), 2),
                    "SubscriptionName": lambda x: ", ".join(sorted(set(x))),
                    "LicensePlate": lambda x: ", ".join(sorted(set(x))),
                }
            )
            .reset_index()
        )

        # Rename and calculate all required columns
        summary_df.columns = [
            "Account Coding",
            "Expense Authority",
            "Total Spend (CAD)",
            "Subscriptions",
            "Projects",
        ]

        # Calculate taxes and fees (using Decimal for precise calculations)
        summary_df["Total Spend (CAD)"] = summary_df["Total Spend (CAD)"].apply(
            lambda x: Decimal(str(x)).quantize(Decimal("0.01"), rounding=ROUND_HALF_UP)
        )

        summary_df["Vendor PST"] = summary_df["Total Spend (CAD)"] * Decimal("0.07")
        summary_df["Vendor Sub-total"] = (
            summary_df["Total Spend (CAD)"] + summary_df["Vendor PST"]
        )

        # Calculate brokerage fee
        summary_df["Brokerage Fee (6%)"] = summary_df["Total Spend (CAD)"] * Decimal(
            "0.06"
        )

        # Calculate grand total
        summary_df["Grand Total"] = (
            summary_df["Vendor Sub-total"] + summary_df["Brokerage Fee (6%)"]
        )

        # Round all decimal columns to 2 decimal places
        decimal_columns = [
            "Total Spend (CAD)",
            "Vendor PST",
            "Vendor Sub-total",
            "Brokerage Fee (6%)",
            "Grand Total",
        ]
        for col in decimal_columns:
            summary_df[col] = summary_df[col].apply(
                lambda x: x.quantize(Decimal("0.01"), rounding=ROUND_HALF_UP)
            )

        # Reorder columns as requested
        summary_df = summary_df[
            [
                "Account Coding",
                "Projects",
                "Total Spend (CAD)",
                "Vendor PST",
                "Vendor Sub-total",
                "Brokerage Fee (6%)",
                "Grand Total",
                "Expense Authority",
            ]
        ]

        return df, summary_df

    except Exception as e:
        print("\nDetailed error information:")
        print(f"Error type: {type(e).__name__}")
        print(f"Error message: {str(e)}")
        print(f"Error class: {e.__class__.__name__}")
        if hasattr(e, "__dict__"):
            print(f"Error attributes: {e.__dict__}")
        raise


# -----------------------------------------------------------------------------
# Monthly Spend Report
#
# This report generates Avg/Last Month/Peak monthly spend plus a Coefficient-
# of-Variation (CV) based "Variability" classification, optionally adding
# project metadata from a Registry export CSV (e.g. public-cloud-products.csv).
#
# -----------------------------------------------------------------------------

REGISTRY_FIELD_ALIASES = {
    "LicensePlate": ["licence plate", "license plate"],
    "ProjectName": ["name", "project name"],
    "Description": ["description"],
    "ReasonDescription": [
        "description of selected reasons",
        "description of reasons for selecting cloud",
    ],
    "ProjectOwnerName": ["project owner name", "project owner"],
    "CreateDate": ["create date", "created date"],
}


def load_registry_csv(registry_csv_path):
    """
    Load a Registry export CSV and normalize its headers to canonical field names. 
    Returns an empty DataFrame if the file is missing so that the Monthly Spend Report
    can still be produced from Azure cost data alone.
    """
    try:
        registry_df = pd.read_csv(registry_csv_path, dtype=str)
    except Exception as e:
        print(f"Warning: Could not read Registry CSV '{registry_csv_path}': {e}")
        return pd.DataFrame(columns=list(REGISTRY_FIELD_ALIASES.keys()))

    normalized_headers = {col.strip().lower(): col for col in registry_df.columns}

    clean = pd.DataFrame()
    for canonical_name, aliases in REGISTRY_FIELD_ALIASES.items():
        source_col = next((normalized_headers[a] for a in aliases if a in normalized_headers), None)
        clean[canonical_name] = registry_df[source_col] if source_col is not None else ""

    if (clean["LicensePlate"] == "").all():
        print(
            f"Warning: Registry CSV '{registry_csv_path}' has no recognizable 'License plate' "
            "column; project metadata cannot be joined to Azure costs."
        )

    # Licence plate is the authoritative join key; normalize case/whitespace before joining.
    clean["LicensePlate"] = clean["LicensePlate"].astype(str).str.strip().str.lower()
    clean = clean[clean["LicensePlate"] != ""]
    clean = clean.drop_duplicates(subset="LicensePlate", keep="first")
    return clean


def aggregate_project_monthly_costs(cost_detail_df):
    if cost_detail_df.empty:
        return pd.DataFrame(columns=["LicensePlate", "Date", "Cost"])

    monthly = cost_detail_df.groupby(["LicensePlate", "Date"], as_index=False)["Cost"].sum()
    return monthly.sort_values(["LicensePlate", "Date"])


def _tagged_expense_authority(values):
    return next((v for v in values if v and v != "Untagged"), "")


def resolve_project_expense_authority(cost_detail_df):
    """
    Roll up subscription-level Expense Authority tags to one value per project License Plate.
    """
    if cost_detail_df.empty or "ExpenseAuthority" not in cost_detail_df.columns:
        return pd.DataFrame(columns=["LicensePlate", "ExpenseAuthority"])

    result = cost_detail_df.groupby("LicensePlate")["ExpenseAuthority"].apply(_tagged_expense_authority)
    return result.reset_index()


def compute_project_spend_metrics(project_monthly_df):
    """
    Compute Avg/Last/Peak monthly spend and Coefficient of Variation based classification per project,
    using only actual months present in the export (never assume $0 for months with no data).
    """
    metrics = []
    for license_plate, group in project_monthly_df.groupby("LicensePlate"):
        monthly_costs = group.sort_values("Date")["Cost"].tolist()
        if not monthly_costs:
            continue

        # A $0.00 first month is almost always a partial billing period, not real spend, so we can exclude it from metrics.
        stats_costs = monthly_costs
        if len(monthly_costs) > 1 and round(monthly_costs[0], 2) == 0.00:
            print(f"Info: [{license_plate}] excluding $0.00 first month from statistics (first-month-zero rule).")
            stats_costs = monthly_costs[1:]

        included_months = len(stats_costs)
        avg_monthly_spend = sum(stats_costs) / included_months
        last_month_spend = monthly_costs[-1]
        peak_month_spend = max(monthly_costs)

        if included_months > 1:
            variance = sum((c - avg_monthly_spend) ** 2 for c in stats_costs) / included_months
            std_dev = variance ** 0.5
        else:
            std_dev = 0.0
            print(f"Info: [{license_plate}] only a single month of history is available; variability is not meaningful.")

        cv = (std_dev / avg_monthly_spend) if avg_monthly_spend else 0.0

        # Variability Classification: First check if the project is Dormant. 
        # Otherwise, Stable / Variable / Burst are selected based on the CV.
        last_three_months = monthly_costs[-3:]
        if len(last_three_months) == 3 and all(c < 1.0 for c in last_three_months):
            classification = "Dormant"
        elif cv < 0.5:
            classification = "Stable"
        elif cv <= 1.5:
            classification = "Variable"
        else:
            classification = "Burst / Seasonal"

        print(
            f"Info: [{license_plate}] months={included_months} avg=${avg_monthly_spend:.2f} "
            f"last=${last_month_spend:.2f} peak=${peak_month_spend:.2f} cv={cv:.2f} -> {classification}"
        )

        metrics.append(
            {
                "LicensePlate": license_plate,
                "AvgMonthlySpend": round(avg_monthly_spend, 2),
                "LastMonthSpend": round(last_month_spend, 2),
                "PeakMonthSpend": round(peak_month_spend, 2),
                "CoefficientOfVariation": round(cv, 4),
                "Variability": classification,
            }
        )

    return pd.DataFrame(metrics)


def build_monthly_spend_report(cost_detail_df, registry_df, platform="Azure"):
    """
    Build the Monthly Spend Report by joining project-level spend statistics with Registry export metadata on License Plate. 
    """
    project_monthly = aggregate_project_monthly_costs(cost_detail_df)
    spend_metrics = compute_project_spend_metrics(project_monthly)
    ea_by_project = resolve_project_expense_authority(cost_detail_df)

    if spend_metrics.empty:
        print("Warning: no Azure cost data available; Monthly Spend Report will only include Registry metadata.")
    if registry_df.empty:
        print("Warning: no Registry data available; Monthly Spend Report will only include Azure spend metrics.")

    report = pd.merge(spend_metrics, ea_by_project, on="LicensePlate", how="outer")
    report = pd.merge(report, registry_df, on="LicensePlate", how="outer", indicator=True)

    # Warn if projects are missing data after the join instead of silently dropping rows
    azure_only = sorted(report.loc[report["_merge"] == "left_only", "LicensePlate"].tolist())
    registry_only = sorted(report.loc[report["_merge"] == "right_only", "LicensePlate"].tolist())
    if azure_only:
        print(f"Warning: {len(azure_only)} project(s) have Azure cost data but no Registry record: {azure_only}")
    if registry_only:
        print(f"Warning: {len(registry_only)} Registry record(s) have no matching Azure cost data: {registry_only}")
    report = report.drop(columns=["_merge"])

    report["Platform"] = platform
    report = report.fillna("")

    column_map = {
        "Platform": "Platform",
        "LicensePlate": "License Plate",
        "ProjectName": "Project Name",
        "Description": "Description",
        "ReasonDescription": "Description of Reasons for Selecting Cloud",
        "ProjectOwnerName": "PO",
        "ExpenseAuthority": "EA",
        "CreateDate": "Project Creation Date",
        "AvgMonthlySpend": "Avg Monthly Spend",
        "LastMonthSpend": "Last Month Spend",
        "PeakMonthSpend": "Peak Month Spend",
        "Variability": "Variability",
        "CoefficientOfVariation": "Variability (CV)",
    }
    for source_col in column_map:
        if source_col not in report.columns:
            report[source_col] = ""

    report = report.rename(columns=column_map)[list(column_map.values())]
    return report.sort_values("Project Name").reset_index(drop=True)


if __name__ == "__main__":
    import argparse

    # Set up argument parser
    parser = argparse.ArgumentParser(
        description="Query Azure Cost Management for subscription costs"
    )
    parser.add_argument(
        "-m",
        "--months",
        type=int,
        default=1,
        help="Number of previous months to include (default: 1)",
    )
    parser.add_argument(
        "--mgmt-group",
        type=str,
        default="bcgov-managed-lz-live-landing-zones",
        help="Starting management group ID for hierarchy traversal (default: bcgov-managed-lz-live-landing-zones)",
    )
    parser.add_argument(
        "--mgmt-group-decom",
        type=str,
        default="bcgov-managed-lz-live-decommissioned",
        help="Name of the decommissioned management group (default: bcgov-managed-lz-decommissioned)",
    )
    parser.add_argument(
        "--include-decom",
        action="store_true",
        help="Include the decommissioned management group in the cost recovery report",
    )
    parser.add_argument(
        "--granularity",
        type=str,
        default="Monthly",
        choices=["Daily", "Monthly", "None"],
        help="Granularity of the cost report (default: Monthly)",
    )
    parser.add_argument(
        "--output-prefix",
        type=str,
        default="azure_cost_recovery",
        help="Prefix for output files (default: azure_cost_recovery)",
    )
    parser.add_argument(
        "--start-date",
        type=str,
        default=None,
        help="Custom start date for the report period (YYYY-MM-DD). Overrides `--months` if set.",
    )
    parser.add_argument(
        "--end-date",
        type=str,
        default=None,
        help="Custom end date for the report period (YYYY-MM-DD). Overrides `--months` if set.",
    )
    parser.add_argument(
        "--monthly-spend-report",
        dest="monthly_spend_report",
        action="store_true",
        help=(
            "Generate a Monthly Spend Report alongside the Cost Recovery report. "
            "Can be used with `--registry-csv` to enrich Azure cost data with project metadata. "
        ),
    )
    parser.add_argument(
        "--registry-csv",
        dest="registry_csv",
        type=str,
        default=None,
        help=(
            "Optional: Path to a Registry export CSV file (e.g. './public-cloud-products.csv'). "
            "Can be used to enrich Azure cost data with project metadata. "
            "Implies `--monthly-spend-report`."
        ),
    )
    args = parser.parse_args()

    mgmt_group = args.mgmt_group
    mgmt_group_decom = args.mgmt_group_decom
    include_decom = args.include_decom
    granularity = args.granularity
    output_prefix = args.output_prefix

    # Get date range based on CLI args
    if args.start_date and args.end_date:
        start = args.start_date
        end = args.end_date
    else:
        today = datetime.now()
        first_of_current = today.replace(day=1)
        last_of_previous = first_of_current - relativedelta(days=1)
        first_of_range = first_of_current - relativedelta(months=args.months)
        start = first_of_range.strftime("%Y-%m-%d")
        end = last_of_previous.strftime("%Y-%m-%d")

    print(f"\nQuerying costs for period: {start} to {end}")
    print(f"Target management group: {mgmt_group}")
    if include_decom:
        print(f"Decommissioned management group: {mgmt_group_decom}")
    print(f"Granularity: {granularity}")

    try:
        # Query target management group
        df_live, _ = get_subscription_costs(mgmt_group, start, end, granularity)
        dfs = [df_live]
        if include_decom:
            df_decom, _ = get_subscription_costs(mgmt_group_decom, start, end, granularity)
            dfs.append(df_decom)
        # Combine the results
        df = pd.concat(dfs, ignore_index=True)

        # Create summary by account coding with tax calculations (repeat logic from get_subscription_costs)
        summary_df = (
            df.groupby(["AccountCoding", "ExpenseAuthority"])
            .agg(
                {
                    "Cost": lambda x: round(sum(x), 2),
                    "SubscriptionName": lambda x: ", ".join(sorted(set(x))),
                    "LicensePlate": lambda x: ", ".join(sorted(set(x))),
                }
            )
            .reset_index()
        )

        summary_df.columns = [
            "Account Coding",
            "Expense Authority",
            "Total Spend (CAD)",
            "Subscriptions",
            "Projects",
        ]

        summary_df["Total Spend (CAD)"] = summary_df["Total Spend (CAD)"].apply(
            lambda x: Decimal(str(x)).quantize(Decimal("0.01"), rounding=ROUND_HALF_UP)
        )
        summary_df["Vendor PST"] = summary_df["Total Spend (CAD)"] * Decimal("0.07")
        summary_df["Vendor Sub-total"] = summary_df["Total Spend (CAD)"] + summary_df["Vendor PST"]
        summary_df["Brokerage Fee (6%)"] = summary_df["Total Spend (CAD)"] * Decimal("0.06")
        summary_df["Grand Total"] = summary_df["Vendor Sub-total"] + summary_df["Brokerage Fee (6%)"]

        decimal_columns = [
            "Total Spend (CAD)",
            "Vendor PST",
            "Vendor Sub-total",
            "Brokerage Fee (6%)",
            "Grand Total",
        ]
        for col in decimal_columns:
            summary_df[col] = summary_df[col].apply(
                lambda x: x.quantize(Decimal("0.01"), rounding=ROUND_HALF_UP)
            )

        summary_df = summary_df[
            [
                "Account Coding",
                "Projects",
                "Total Spend (CAD)",
                "Vendor PST",
                "Vendor Sub-total",
                "Brokerage Fee (6%)",
                "Grand Total",
                "Expense Authority",
            ]
        ]

        if df.empty:
            print("\nNo data returned from the query")
        else:
            print("\nCosts by Account Coding:")
            print(summary_df.to_string(index=False))
            print("\nDetailed Subscription Costs:")
            print(df.to_string(index=False))

            # Export to CSV and Excel
            detail_csv = f"{output_prefix}_detail_{start}_to_{end}.csv"
            summary_csv = f"{output_prefix}_report_{start}_to_{end}.csv"
            summary_xlsx = f"{output_prefix}_report_{start}_to_{end}.xlsx"

            df.to_csv(detail_csv, index=False)
            summary_df.to_csv(summary_csv, index=False)

            # Create Excel writer with formatting
            with pd.ExcelWriter(summary_xlsx, engine="openpyxl") as writer:
                summary_df.to_excel(writer, sheet_name="Cost Recovery", index=False)

                # Get the workbook and worksheet
                workbook = writer.book
                worksheet = writer.sheets["Cost Recovery"]

                # Define formats - Updated for openpyxl
                from openpyxl.styles import Border, Font, PatternFill, Side

                # Create styles
                header_font = Font(bold=True)
                header_fill = PatternFill(
                    start_color="D9D9D9", end_color="D9D9D9", fill_type="solid"
                )
                thin_border = Border(
                    left=Side(style="thin"),
                    right=Side(style="thin"),
                    top=Side(style="thin"),
                    bottom=Side(style="thin"),
                )

                # Apply header formatting
                for col in range(1, len(summary_df.columns) + 1):
                    cell = worksheet.cell(row=1, column=col)
                    cell.font = header_font
                    cell.fill = header_fill
                    cell.border = thin_border

                # Money format for openpyxl
                money_format = '_($* #,##0.00_);_($* (#,##0.00);_($* "-"??_);_(@_)'

                # Set column widths
                worksheet.column_dimensions["A"].width = 20  # Account Coding
                worksheet.column_dimensions["B"].width = 20  # Projects
                worksheet.column_dimensions["C"].width = 15  # Total Spend
                for col in range(4, 8):  # Other monetary columns (D through G)
                    worksheet.column_dimensions[chr(64 + col)].width = 15
                worksheet.column_dimensions["H"].width = 25  # Expense Authority

                # Apply money format to numeric columns
                for col in range(3, 8):  # Columns C through G
                    for row in range(2, len(summary_df) + 2):
                        cell = worksheet.cell(row=row, column=col)
                        cell.number_format = money_format

                # Freeze the header row
                worksheet.freeze_panes = "A2"

            print("\nResults exported to:")
            print(f"  - Detail: {detail_csv}")
            print(f"  - Summary CSV: {summary_csv}")
            print(f"  - Summary Excel: {summary_xlsx}")

        # Avg/Last/Peak/Variability calculations all assume one data point per calendar month
        monthly_spend_report_requested = args.registry_csv or args.monthly_spend_report
        if monthly_spend_report_requested and granularity != "Monthly":
            print(
                f"\nError: Monthly Spend Report requires '--granularity Monthly', but is set to '{granularity}'. Skipping report."
            )
        elif monthly_spend_report_requested:
            if args.registry_csv:
                print(f"\nGenerating Monthly Spend Report using registry file: {args.registry_csv}")
                registry_df = load_registry_csv(args.registry_csv)
            else:
                print("\nGenerating Monthly Spend Report from Azure cost data only (no --registry-csv provided)")
                registry_df = pd.DataFrame(columns=list(REGISTRY_FIELD_ALIASES.keys()))
            monthly_spend_report = build_monthly_spend_report(df, registry_df)

            if monthly_spend_report.empty:
                print("No data available to build the Monthly Spend Report (no Azure costs and no Registry records).")
            else:
                monthly_spend_csv = f"{output_prefix}_monthly_spend_{start}_to_{end}.csv"
                monthly_spend_xlsx = f"{output_prefix}_monthly_spend_{start}_to_{end}.xlsx"
                monthly_spend_report.to_csv(monthly_spend_csv, index=False)

                with pd.ExcelWriter(monthly_spend_xlsx, engine="openpyxl") as writer:
                    monthly_spend_report.to_excel(writer, sheet_name="Monthly Spend Report", index=False)
                    worksheet = writer.sheets["Monthly Spend Report"]

                    from openpyxl.styles import Font, PatternFill

                    header_font = Font(bold=True)
                    header_fill = PatternFill(start_color="D9D9D9", end_color="D9D9D9", fill_type="solid")
                    for col in range(1, len(monthly_spend_report.columns) + 1):
                        cell = worksheet.cell(row=1, column=col)
                        cell.font = header_font
                        cell.fill = header_fill
                    worksheet.freeze_panes = "A2"

                print("\nMonthly Spend Report exported to:")
                print(f"  - CSV: {monthly_spend_csv}")
                print(f"  - Excel: {monthly_spend_xlsx}")

    except Exception as e:
        print(f"\nFailed to retrieve cost data: {str(e)}")
