
$h_data=@{
    "dataSource"="chia-stuff"
    "database"="mydatabase"
    "collection"="customers"
    "projection"= @{
        "name"="John"
    }
}

$h_headers=@{
    "Access-Control-Request-Headers"="*"
    "api-key"=""
}

$result=Invoke-RestMethod -Method Post -Uri "https://data.mongodb-api.com/app/data-tmopi/endpoint/data/v1/action/findOne" -Headers $h_headers -Body (ConvertTo-Json $h_data) -ContentType "application/json"
$result.document