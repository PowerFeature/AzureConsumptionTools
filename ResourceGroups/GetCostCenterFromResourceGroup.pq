/*
	

*/
(SubscriptionID as text, ResourceGroupName as text) as text =>
let
    resourceId  = "/subscriptions/" & SubscriptionID & "/resourceGroups/" & ResourceGroupName,
    SearchResult = Table.SelectRows(ResourceGroups, each [id] = resourceId),
    tagValue = if Table.RowCount(SearchResult) > 0 then SearchResult{0}[#"cost-center"] else "Not Found"
in
    tagValue