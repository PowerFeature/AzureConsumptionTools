/*
This PowerQuery creates a list of all resource groups in accessible to the user, and extract specific tags assigned to the resource groups.
In this case the tags "cost-center" and "legal-unit"
*/
let
    Source = Json.Document(Web.Contents("https://management.azure.com/subscriptions?api-version=2020-01-01")),
    #"Converted to Table" = Table.FromRecords({Source}),
    #"Extract Value" = #"Converted to Table"{0}[value],
    #"Expand Records" = Table.FromList(#"Extract Value", Splitter.SplitByNothing(), null, null, ExtraValues.Error),
    Subscriptions = #"Expand Records",
    #"Expanded Column1" = Table.ExpandRecordColumn(Subscriptions, "Column1", {"id", "managedByTenants", "tags", "subscriptionId", "tenantId", "displayName", "state"}, {"id", "managedByTenants", "tags", "subscriptionId", "tenantId", "displayName", "state"}),
    #"Removed Columns" = Table.RemoveColumns(#"Expanded Column1",{"tags", "managedByTenants", "id", "tenantId", "displayName"}),
    #"Invoked Custom Function" = Table.AddColumn(#"Removed Columns", "ResourceGroups", each GetResourceGroups([subscriptionId], {"cost-center", "legal-unit"})),
    #"Expanded ResourceGroups" = Table.ExpandTableColumn(#"Invoked Custom Function", "ResourceGroups", {"id", "name", "cost-center", "legal-unit"}, {"id", "name", "cost-center", "legal-unit"}),
    #"Removed Empty Id's" = Table.SelectRows(#"Expanded ResourceGroups", each [id] <> null and [id] <> ""),
    #"Removed Empty cost-centers" = Table.SelectRows(#"Removed Empty Id's", each [#"cost-center"] <> null and [#"cost-center"] <> ""),
    #"Removed Empty legal-units" = Table.SelectRows(#"Removed Empty cost-centers", each [#"legal-unit"] <> null and [#"legal-unit"] <> "")
in
    #"Removed Empty legal-units"