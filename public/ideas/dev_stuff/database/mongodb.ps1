
$h_data=@{
    "dataSource"="chia-stuff"
    "database"="mydatabase"
    "collection"="customers"
    "projection"= @{
        "name"="John"
    }
}

$h_headers=@{
#    "Content-Type"="application/json"
    "Access-Control-Request-Headers"="*"
    "api-key"="NUa94kGHaaZFIJtgWCF0o06BQDEqvx5bAsDDJmuZXb4gp8kEWfTcxsoNq7xskv1B"
}

$result=Invoke-RestMethod -Method Post -Uri "https://data.mongodb-api.com/app/data-tmopi/endpoint/data/v1/action/findOne" -Headers $h_headers -Body (ConvertTo-Json $h_data) -ContentType "application/json"
$result.document