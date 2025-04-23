import argparse
from azure.identity import DefaultAzureCredential
from azure.mgmt.authorization import AuthorizationManagementClient
from azure.mgmt.managementgroups import ManagementGroupsAPI
from azure.mgmt.resource import ResourceManagementClient
from msgraph import GraphServiceClient
import csv
from datetime import datetime
import logging
import asyncio

# Configure logging
# Set all loggers to WARNING by default
logging.getLogger().setLevel(logging.WARNING)

# Configure our logger
logger = logging.getLogger(__name__)
logger.setLevel(logging.INFO)

# Create console handler with formatting
console_handler = logging.StreamHandler()
console_handler.setFormatter(logging.Formatter('%(asctime)s - %(name)s - %(levelname)s - %(message)s'))
logger.addHandler(console_handler)

async def get_user_details_async(credential, principal_id):
    """Get user details from Microsoft Graph API"""
    try:
        # Create Graph client with proper scopes
        scopes = ["https://graph.microsoft.com/.default"]
        graph_client = GraphServiceClient(credentials=credential, scopes=scopes)
        
        # Try to get user by object ID (principal ID)
        try:
            user = await graph_client.users.by_user_id(principal_id).get()
            if user:
                return {
                    'display_name': user.display_name or 'N/A',
                    'user_principal_name': user.user_principal_name or 'N/A',
                    'email': user.mail or user.user_principal_name or 'N/A'
                }
        except Exception as e:
            # If user lookup fails, try service principal
            try:
                sp = await graph_client.service_principals.by_service_principal_id(principal_id).get()
                if sp:
                    return {
                        'display_name': sp.display_name or 'N/A',
                        'user_principal_name': sp.app_id or 'N/A',
                        'email': sp.service_principal_type or 'N/A'
                    }
            except Exception as sp_e:
                logger.debug(f"Could not get service principal details: {str(sp_e)}")
    except Exception as e:
        logger.debug(f"Could not get user/sp details for principal {principal_id}: {str(e)}")
    
    return {
        'display_name': 'N/A',
        'user_principal_name': 'N/A',
        'email': 'N/A'
    }

def get_user_details(credential, principal_id):
    """Synchronous wrapper for get_user_details_async"""
    return asyncio.run(get_user_details_async(credential, principal_id))

def get_subscriptions_under_mg(credential, management_group_id):
    """Get all subscriptions under a management group"""
    logger.info(f"Searching for subscriptions under management group: {management_group_id}")
    mg_client = ManagementGroupsAPI(credential)
    subscriptions = []
    
    # Get all subscriptions under the management group
    try:
        for subscription in mg_client.management_group_subscriptions.get_subscriptions_under_management_group(management_group_id):
            logger.info(f"Found subscription - Name: {subscription.display_name}, ID: {subscription.name}")
            subscriptions.append(subscription.name)  # subscription.name is the subscription ID
    except Exception as e:
        logger.error(f"Error while getting subscriptions: {str(e)}", exc_info=True)
    
    logger.info(f"Total subscriptions found: {len(subscriptions)}")
    return subscriptions

def get_subscription_resources(credential, subscription_id):
    """Get all resources in a subscription"""
    logger.info(f"Getting resources for subscription: {subscription_id}")
    resource_client = ResourceManagementClient(credential, subscription_id)
    resources = []
    
    try:
        # Get all resources in the subscription directly
        for resource in resource_client.resources.list():
            resources.append({
                'id': resource.id,
                'name': resource.name,
                'type': resource.type,
                'location': resource.location,
                'subscription_id': subscription_id
            })
        logger.info(f"Found {len(resources)} resources in subscription {subscription_id}")
    except Exception as e:
        logger.error(f"Error getting resources for subscription {subscription_id}: {str(e)}")
    
    return resources

def get_role_assignments(credential, scope, subscription_id):
    """Get all role assignments at a given scope"""
    auth_client = AuthorizationManagementClient(credential, subscription_id)
    assignments = []
    
    for assignment in auth_client.role_assignments.list_for_scope(scope):
        assignments.append(assignment)
    
    return assignments

def get_role_definition(credential, subscription_id, role_definition_id):
    """Get role definition details"""
    auth_client = AuthorizationManagementClient(credential, subscription_id)
    return auth_client.role_definitions.get_by_id(role_definition_id)

def is_data_plane_role(role_definition):
    """Check if a role is a data plane role by looking at its data_actions"""
    return bool(
        getattr(role_definition.permissions[0], 'data_actions', None) or 
        getattr(role_definition.permissions[0], 'not_data_actions', None)
    )

def generate_report(credential, management_group_id, output_file, exclude_data_plane=False):
    """Generate report of direct user role assignments"""
    all_assignments = []
    all_resources = []
    
    # Get subscriptions under the management group
    subscriptions = get_subscriptions_under_mg(credential, management_group_id)
    if not subscriptions:
        logger.error(f"No subscriptions found under management group {management_group_id}")
        return
        
    # Use first subscription for management group level queries
    first_subscription = subscriptions[0]
    
    # Get assignments for management group scope
    try:
        # Only get assignments directly on this management group
        mg_scope = f"/providers/Microsoft.Management/managementGroups/{management_group_id}"
        assignments = get_role_assignments(credential, mg_scope, first_subscription)
        all_assignments.extend(assignments)
        logger.info(f"Found {len(assignments)} role assignments at management group level")
    except Exception as e:
        logger.warning(f"Could not get role assignments for management group {management_group_id}: {str(e)}")
    
    # Get assignments and resources for each subscription under the management group
    for subscription_id in subscriptions:
        # Get resources
        subscription_resources = get_subscription_resources(credential, subscription_id)
        all_resources.extend(subscription_resources)
        
        # Get role assignments
        subscription_scope = f"/subscriptions/{subscription_id}"
        try:
            assignments = get_role_assignments(credential, subscription_scope, subscription_id)
            all_assignments.extend(assignments)
            logger.info(f"Found {len(assignments)} role assignments in subscription {subscription_id}")
        except Exception as e:
            logger.warning(f"Could not get role assignments for subscription {subscription_id}: {str(e)}")
    
    logger.info(f"Found {len(all_assignments)} total role assignments across {len(subscriptions)} subscriptions")
    logger.info(f"Found {len(all_resources)} total resources across {len(subscriptions)} subscriptions")
    
    # Filter for direct user assignments and prepare report data
    report_data = []
    data_plane_roles_skipped = 0
    for assignment in all_assignments:
        try:
            # Skip assignments that aren't directly on our management group or its subscriptions
            assignment_scope = assignment.scope.lower()
            mg_scope = f"/providers/microsoft.management/managementgroups/{management_group_id}".lower()
            
            is_valid_scope = (
                assignment_scope == mg_scope or  # Direct on our management group
                any(f"/subscriptions/{sub_id}".lower() in assignment_scope for sub_id in subscriptions)  # In our subscriptions
            )
            
            if not is_valid_scope:
                continue
            
            # Get the subscription ID from the scope
            subscription_id = assignment.scope.split('/subscriptions/')[1].split('/')[0] if '/subscriptions/' in assignment.scope else first_subscription
            
            # Get role definition
            role_definition = get_role_definition(credential, subscription_id, assignment.role_definition_id)
            
            # Skip data plane roles if exclude flag is set
            if exclude_data_plane and is_data_plane_role(role_definition):
                data_plane_roles_skipped += 1
                logger.debug(f"Skipping data plane role: {role_definition.role_name}")
                continue
            
            # Only include if it's a user assignment (principal_type might be None, so check the ID format)
            if hasattr(assignment, 'principal_type') and assignment.principal_type == 'User' or (
                assignment.principal_id and '@' in assignment.principal_id
            ):
                # Get user details for principal
                principal_details = get_user_details(credential, assignment.principal_id)
                
                # Get creator details if available
                creator_details = {'email': 'N/A', 'display_name': 'N/A'}
                if hasattr(assignment, 'created_by') and assignment.created_by:
                    creator_details = get_user_details(credential, assignment.created_by)
                
                report_data.append({
                    'User Principal ID': assignment.principal_id,
                    'User Email': principal_details['email'],
                    'User Display Name': principal_details['display_name'],
                    'Principal Type': assignment.principal_type if hasattr(assignment, 'principal_type') else 'Unknown',
                    'Role Name': role_definition.role_name,
                    'Scope': assignment.scope,
                    'Assignment Type': 'Direct',
                    'Created On': assignment.created_on.strftime('%Y-%m-%d %H:%M:%S') if assignment.created_on else 'N/A',
                    'Created By Email': creator_details['email'],
                    'Created By Display Name': creator_details['display_name']
                })
        except Exception as e:
            logger.warning(f"Could not process role assignment {assignment.id}: {str(e)}")
            continue
    
    if exclude_data_plane:
        logger.info(f"Writing {len(report_data)} user role assignments to report (excluded {data_plane_roles_skipped} data plane roles)")
    else:
        logger.info(f"Writing {len(report_data)} user role assignments to report (including data plane roles)")
    
    # Write report to CSV
    with open(output_file, 'w', newline='') as csvfile:
        fieldnames = ['User Principal ID', 'User Email', 'User Display Name', 'Principal Type', 'Role Name', 'Scope', 
                     'Assignment Type', 'Created On', 'Created By Email', 'Created By Display Name']
        writer = csv.DictWriter(csvfile, fieldnames=fieldnames)
        
        writer.writeheader()
        for row in report_data:
            writer.writerow(row)
    
    logger.info(f"Report generated successfully: {output_file}")

def main():
    parser = argparse.ArgumentParser(description='Generate report of direct user role assignments in Azure')
    parser.add_argument('--management-group-id', required=True, help='Management group ID to analyze')
    parser.add_argument('--output-file', default='role_assignments_report.csv', help='Output CSV file path')
    parser.add_argument('--exclude-data-plane', action='store_true', help='Exclude data plane role assignments from the report')
    
    args = parser.parse_args()
    
    # Initialize Azure credentials
    credential = DefaultAzureCredential()
    
    try:
        generate_report(credential, args.management_group_id, args.output_file, args.exclude_data_plane)
    except Exception as e:
        logger.error(f"Error generating report: {str(e)}", exc_info=True)
        raise

if __name__ == "__main__":
    main()
