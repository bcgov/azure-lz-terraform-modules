#!/usr/bin/env python3

import argparse
import csv
import json
import os
import subprocess
import sys
from typing import Any, TextIO


DEFAULT_FIELDS = ["name", "resourceGroup", "location", "id"]


def run_az_json(args: list[str]) -> Any:
    result = subprocess.run(
        ["az", *args],
        check=True,
        capture_output=True,
        text=True,
    )
    output = result.stdout.strip()
    return json.loads(output) if output else []


def parse_resource_group(resource_id: str) -> str:
    parts = resource_id.split("/")
    try:
        return parts[parts.index("resourceGroups") + 1]
    except (ValueError, IndexError):
        return ""


def list_private_dns_zones(
    subscription_id: str,
    resource_group: str | None,
    include_all_private_dns_zones: bool,
) -> list[dict[str, str]]:
    args = [
        "resource",
        "list",
        "--subscription",
        subscription_id,
        "--resource-type",
        "Microsoft.Network/privateDnsZones",
        "-o",
        "json",
    ]
    if resource_group:
        args.extend(["--resource-group", resource_group])

    zones = run_az_json(args)
    rows = []
    for zone in zones:
        name = zone.get("name", "")
        if not include_all_private_dns_zones and "privatelink" not in name.lower():
            continue

        resource_id = zone.get("id", "")
        rows.append(
            {
                "name": name,
                "resourceGroup": zone.get("resourceGroup") or parse_resource_group(resource_id),
                "location": zone.get("location", ""),
                "id": resource_id,
            }
        )

    return sorted(rows, key=lambda row: (row["resourceGroup"].lower(), row["name"].lower()))


def write_json(rows: list[dict[str, str]], output: TextIO) -> None:
    json.dump(rows, output, indent=2)
    output.write("\n")


def write_csv(rows: list[dict[str, str]], output: TextIO) -> None:
    writer = csv.DictWriter(output, fieldnames=DEFAULT_FIELDS)
    writer.writeheader()
    writer.writerows(rows)


def write_text(rows: list[dict[str, str]], output: TextIO) -> None:
    output.write(f"Private Link private DNS zones: {len(rows)}\n")
    if not rows:
        return

    widths = {
        "name": max(len("Name"), *(len(row["name"]) for row in rows)),
        "resourceGroup": max(len("Resource group"), *(len(row["resourceGroup"]) for row in rows)),
    }
    output.write(f"{'Name'.ljust(widths['name'])}  {'Resource group'.ljust(widths['resourceGroup'])}  Id\n")
    output.write(f"{'-' * widths['name']}  {'-' * widths['resourceGroup']}  {'-' * 2}\n")
    for row in rows:
        output.write(
            f"{row['name'].ljust(widths['name'])}  "
            f"{row['resourceGroup'].ljust(widths['resourceGroup'])}  "
            f"{row['id']}\n"
        )


def write_domains(rows: list[dict[str, str]], output: TextIO) -> None:
    for row in rows:
        output.write(f"{row['name']}\n")


def write_output(
    rows: list[dict[str, str]],
    output_format: str,
    output_file: str | None,
    domains_only: bool,
) -> None:
    output = open(output_file, "w", newline="") if output_file else sys.stdout
    try:
        if domains_only:
            write_domains(rows, output)
        elif output_format == "json":
            write_json(rows, output)
        elif output_format == "csv":
            write_csv(rows, output)
        else:
            write_text(rows, output)
    finally:
        if output_file:
            output.close()


def main() -> int:
    default_subscription = os.getenv("AZURE_CONNECTIVITY_SUBSCRIPTION_ID") or os.getenv("AZURE_SUBSCRIPTION_ID")

    parser = argparse.ArgumentParser(
        description="List Private Link private DNS zones deployed in the connectivity subscription."
    )
    parser.add_argument(
        "--subscription-id",
        "--subscription",
        "-s",
        default=default_subscription,
        help=(
            "Connectivity subscription ID. Defaults to AZURE_CONNECTIVITY_SUBSCRIPTION_ID, "
            "then AZURE_SUBSCRIPTION_ID."
        ),
    )
    parser.add_argument(
        "--resource-group",
        "-g",
        help="Optional resource group filter, for example the landing zone DNS resource group.",
    )
    parser.add_argument(
        "--include-all-private-dns-zones",
        action="store_true",
        help="Include all private DNS zones instead of only zones whose name contains 'privatelink'.",
    )
    parser.add_argument("--output", "-o", choices=["text", "json", "csv"], default="text")
    parser.add_argument("--output-file", help="Optional path to write output instead of stdout.")
    parser.add_argument(
        "--domains-only",
        action="store_true",
        help="Output only raw domain names, one per line.",
    )
    args = parser.parse_args()

    if not args.subscription_id:
        parser.error(
            "the connectivity subscription ID is required. Pass --subscription-id or set "
            "AZURE_CONNECTIVITY_SUBSCRIPTION_ID."
        )

    zones = list_private_dns_zones(
        args.subscription_id,
        args.resource_group,
        args.include_all_private_dns_zones,
    )
    write_output(zones, args.output, args.output_file, args.domains_only)
    return 0


if __name__ == "__main__":
    try:
        raise SystemExit(main())
    except subprocess.CalledProcessError as error:
        if error.stderr:
            sys.stderr.write(error.stderr)
        raise SystemExit(error.returncode)
