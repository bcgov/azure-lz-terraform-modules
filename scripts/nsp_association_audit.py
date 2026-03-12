#!/usr/bin/env python3

import argparse
import json
import subprocess
import sys
from typing import Any


def run_az_json(args: list[str]) -> Any:
    result = subprocess.run(
        ["az", *args],
        check=True,
        capture_output=True,
        text=True,
    )
    output = result.stdout.strip()
    return json.loads(output) if output else []


def list_tagged_resources(
    subscription_id: str,
    resource_group: str | None,
    tag_name: str,
    tag_value: str,
) -> list[dict[str, Any]]:
    query = (
        f"[?tags.{tag_name}=='{tag_value}']."
        "{id:id,name:name,type:type,location:location}"
    )
    args = ["resource", "list", "--subscription", subscription_id]
    if resource_group:
        args.extend(["-g", resource_group])
    args.extend(["--query", query, "-o", "json"])
    return run_az_json(args)


def list_nsp_associations(
    subscription_id: str,
    resource_group: str,
    nsp_name: str,
    profile_id: str | None,
) -> list[dict[str, Any]]:
    url = (
        "https://management.azure.com/subscriptions/"
        f"{subscription_id}/resourceGroups/{resource_group}"
        "/providers/Microsoft.Network/networkSecurityPerimeters/"
        f"{nsp_name}/resourceAssociations?api-version=2025-05-01"
    )
    response = run_az_json(["rest", "--method", "get", "--url", url, "-o", "json"])
    items = response.get("value", [])
    if profile_id:
        items = [
            item
            for item in items
            if item.get("properties", {}).get("profile", {}).get("id") == profile_id
        ]
    return items


def print_section(title: str, rows: list[dict[str, Any]]) -> None:
    print(f"\n{title}: {len(rows)}")
    for row in rows:
        print(f"- {row['id']} | {row['type']}")


def main() -> int:
    parser = argparse.ArgumentParser(
        description=(
            "Audit cross-subscription NSP association compliance by comparing tagged "
            "resources in a source subscription with actual NSP resourceAssociations."
        )
    )
    parser.add_argument("--source-subscription", required=True)
    parser.add_argument("--source-resource-group")
    parser.add_argument("--target-subscription", required=True)
    parser.add_argument("--target-resource-group", required=True)
    parser.add_argument("--nsp-name", required=True)
    parser.add_argument("--profile-id")
    parser.add_argument("--tag-name", default="SecuredByPerimeter")
    parser.add_argument("--tag-value", default="true")
    parser.add_argument("--output", choices=["text", "json"], default="text")
    args = parser.parse_args()

    tagged_resources = list_tagged_resources(
        args.source_subscription,
        args.source_resource_group,
        args.tag_name,
        args.tag_value,
    )
    associations = list_nsp_associations(
        args.target_subscription,
        args.target_resource_group,
        args.nsp_name,
        args.profile_id,
    )

    association_map = {}
    for association in associations:
        properties = association.get("properties", {})
        resource_id = properties.get("privateLinkResource", {}).get("id")
        if resource_id:
            association_map[resource_id.lower()] = {
                "id": association.get("id"),
                "name": association.get("name"),
                "type": association.get("type"),
                "provisioningState": properties.get("provisioningState"),
                "profileId": properties.get("profile", {}).get("id"),
                "privateLinkResourceId": resource_id,
            }

    tagged_map = {resource["id"].lower(): resource for resource in tagged_resources}

    matched = []
    missing = []
    for resource in tagged_resources:
        association = association_map.get(resource["id"].lower())
        if association:
            matched.append({**resource, "associationId": association["id"]})
        else:
            missing.append(resource)

    orphaned = []
    for resource_id, association in association_map.items():
        if resource_id not in tagged_map:
            orphaned.append(
                {
                    "id": association["privateLinkResourceId"],
                    "type": "AssociatedButNotTagged",
                    "associationId": association["id"],
                }
            )

    summary = {
        "taggedResourceCount": len(tagged_resources),
        "associationCount": len(associations),
        "matchedCount": len(matched),
        "missingCount": len(missing),
        "orphanedCount": len(orphaned),
        "matched": matched,
        "missing": missing,
        "orphaned": orphaned,
    }

    if args.output == "json":
        print(json.dumps(summary, indent=2))
    else:
        print("NSP Association Audit")
        print(f"Tagged resources: {summary['taggedResourceCount']}")
        print(f"Associations: {summary['associationCount']}")
        print(f"Matched: {summary['matchedCount']}")
        print(f"Missing: {summary['missingCount']}")
        print(f"Orphaned: {summary['orphanedCount']}")
        print_section("Missing tagged resources", missing)
        print_section("Orphaned associations", orphaned)

    return 0 if not missing else 2


if __name__ == "__main__":
    try:
        raise SystemExit(main())
    except subprocess.CalledProcessError as error:
        sys.stderr.write(error.stderr)
        raise SystemExit(error.returncode)