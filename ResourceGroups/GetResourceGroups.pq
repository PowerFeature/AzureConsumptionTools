/*
This Function gets the RessourceGroups from a subscription. It can be used in conjunction with a complete subscription list to get all ressourcegroups for a scope e.g. management group. 
Inputs:
SubscriptionId xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx text the subscriptionId to get resourcegroups from
tagNames {tag1, tag2} list of tagnames to be extracted into the reulting table.

*/
(SubscriptionId as text, tagNames as list) as table =>
let

    Source = Web.Contents("https://management.azure.com/subscriptions/" & SubscriptionId & "/resourcegroups?api-version=2020-10-01",        [
            ManualStatusHandling = {400,401,403,404,429,500,503}
        ]),
        responseMetadata = Value.Metadata(Source),
        responseCode = responseMetadata[Response.Status],
    json = if responseCode <> 200 then Json.Document({}) else Json.Document(Source),

    #"Converted to Table" = Table.FromRecords({json}),
    #"Expanded value" = Table.ExpandListColumn(#"Converted to Table", "value"),
    #"Expanded value1" = Table.ExpandRecordColumn(#"Expanded value", "value", {"id","name","tags"}, null),

    #"Expanded tags" = if responseCode = 200 then Table.ExpandRecordColumn(#"Expanded value1", "tags", tagNames, tagNames) else Table.FromRecords({})
in
    #"Expanded tags"