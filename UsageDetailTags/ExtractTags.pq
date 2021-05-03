/*
This Function takes the tag structure from the Azure API Billing API e.g. 
"owner": "ABC","expiration-date": ""one","creator": "xxx@microsoft.com","cost-center": "451244 Dev"
and turn it into a Record by adding { } around and converting it to JSON.

The function can be added with invoke Custom function and specific tags can be extracted. 
*/
(TagsText as text) as record =>
let
    jsonTags = "{" & TagsText & "}",
    JsonRecord = Json.Document(jsonTags)
in
    JsonRecord