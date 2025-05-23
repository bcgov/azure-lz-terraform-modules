{
    "runAfter": {
        "Initialize_AffectedResource_Variable": [
            "Succeeded"
        ]
    },
    "description": "",
    "type": "ApiConnection",
    "inputs": {
        "host": {
            "connection": {
                "name": "@parameters('$connections')['${api_connection_name}']['connectionId']"
            }
        },
        "method": "post",
        "body": {
            "fields": {
                "summary": "@{triggerBody()?['data']?['essentials']?['severity']} Azure Monitor Alert - @{triggerBody()?['data']?['essentials']?['description']} on @{variables('AffectedResource')[8]} (@{concat(variables('AffectedResource')[6], '/', variables('AffectedResource')[7])}) at @{formatDateTime(triggerBody()?['data']?['essentials']?['firedDateTime'], 'MM/dd/yyyy h:mm:ss tt UTC', 'en-CA')}",
                "description": "h1. @{triggerBody()?['data']?['essentials']?['severity']} Azure Monitor Alert - @{triggerBody()?['data']?['essentials']?['description']} on @{variables('AffectedResource')[8]} (@{concat(variables('AffectedResource')[6], '/', variables('AffectedResource')[7])}) at @{formatDateTime(triggerBody()?['data']?['essentials']?['firedDateTime'], 'MM/dd/yyyy h:mm:ss tt UTC', 'en-CA')}\n\nh2. Quick Links\n- [View the alert in Azure Monitor|@{concat('https://portal.azure.com/#view/Microsoft_Azure_Monitoring_Alerts/AlertDetails.ReactView/alertId/', encodeUriComponent(triggerBody()?['data']?['essentials']?['alertId']))}]\n- [Investigate with Azure Monitor Investigator (Preview)|@{concat('https://portal.azure.com/#view/Microsoft_Azure_Monitoring_Alerts/Investigation.ReactView/alertId/', encodeUriComponent(triggerBody()?['data']?['essentials']?['alertId']))}]\n\nh1. Summary\n\n- Alert Name: @{triggerBody()?['data']?['essentials']?['alertRule']}\n- Severity: *@{triggerBody()?['data']?['essentials']?['severity']}*\n- Monitor Condition: @{triggerBody()?['data']?['essentials']?['monitorCondition']}\n- Affected Resource: [@{variables('AffectedResource')[8]}|@{concat('https://portal.azure.com/#resource', triggerBody()?['data']?['essentials']?['originAlertId'])}]\n- Resource Type: @{concat(variables('AffectedResource')[6], '/', variables('AffectedResource')[7])}\n- Resource Group: @{variables('AffectedResource')[4]}\n- Description: @{triggerBody()?['data']?['essentials']?['description']}\n- Monitoring Service: @{triggerBody()?['data']?['essentials']?['monitoringService']}\n- Signal Type: @{triggerBody()?['data']?['essentials']?['signalType']}\n- Fired Time: @{formatDateTime(triggerBody()?['data']?['essentials']?['firedDateTime'], 'MMMM dd, yyyy HH:mm UTC', 'en-CA')}\n- Alert ID: [@{last(split(triggerBody()?['data']?['essentials']?['alertId'], '/'))}|@{concat('https://portal.azure.com/#view/Microsoft_Azure_Monitoring_Alerts/AlertDetails.ReactView/alertId/', encodeUriComponent(triggerBody()?['data']?['essentials']?['alertId']))}] \n- Alert Rule ID: [https://portal.azure.com/#resource@{triggerBody()?['data']?['essentials']?['originAlertId']}|@{concat('https://portal.azure.com/#resource', triggerBody()?['data']?['essentials']?['originAlertId'])}]"
            }
        },
        "headers": {
            "X-Request-Jirainstance": "https://citz-do.atlassian.net/"
        },
        "path": "/v3/issue",
        "queries": {
            "projectKey": "PCS",
            "issueTypeIds": "10121"
        }
    }
}
