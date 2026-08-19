# Known Issues

The following policy definitions have known issues that may affect their functionality or behavior. Please review the details below before using these policies in your environment.

## Deny Creating Azure AI Search Services

This custom policy definition, although being a part of the custom policy assignment (`Deny deployment of selected Azure AI Services`), throws a different error message in the Azure portal when a user attempts to create an Azure AI Search Service. The error message displayed is:

```text
The resource deployment was blocked because it does not comply with the Azure Policy requiring customer-managed key (CMK) encryption. To proceed, enable CMK encryption in the Encryption tab.
```

This is despite the policy definition not having a custom non-compliance message configured, and the policy assignment itself having a generic non-compliance message.

According to Copilot:

> Most likely explanation: The CMK wording is a generic/misleading UX message from the Search deployment flow for policy-denied creates, not the actual deny rule that fired in this request.
