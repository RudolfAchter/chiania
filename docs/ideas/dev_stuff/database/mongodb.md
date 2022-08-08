# Cloud Hosted MongoDB Database

We are migrating our Ingame Data to JSON formatted data. To Host and access this data effectively we can use MongoDB.
- <https://cloud.mongodb.com/>

## Python Example

Python integrates very well with mongodb. Feels like you are directly accessing the objects

```python
import pymongo
import dns # required for connecting with SRV
import pprint

myuser="rudi"
mypassword="mypassword"

#, server_api=ServerApi('1')
myclient = pymongo.MongoClient("mongodb+srv://"+myuser+":"+mypassword+"@chia-stuff.g7ivxgh.mongodb.net/?retryWrites=true&w=majority")
db = myclient.test
print(db)

mydb = myclient.mydatabase
mycol = mydb.customers
mydict = { "name": "Herbert", "address": "Trafalgar Square" }
result = mycol.insert_one(mydict)

doc=mycol.find_one({"name": "John"})

pprint.pprint(doc)
```

## HTTP API Example

Powershell MongDB driver doesn't work for me. But with MongDB Atlas i can easily access via HTTP API

### Powershell

```powershell

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
    "api-key"="yourApiKey"
}

$result=Invoke-RestMethod -Method Post -Uri "https://data.mongodb-api.com/app/data-tmopi/endpoint/data/v1/action/findOne" -Headers $h_headers -Body (ConvertTo-Json $h_data) -ContentType "application/json"
$result.document
```

### curl

Even with Bash Scripts we can directly access with curl

```bash
curl --location --request POST 'https://data.mongodb-api.com/app/data-tmopi/endpoint/data/v1/action/findOne' \
--header 'Content-Type: application/json' \
--header 'Access-Control-Request-Headers: *' \
--header 'api-key: yourApiKey' \
--data-raw '{
    "collection":"customers",
    "database":"mydatabase",
    "dataSource":"chia-stuff",
    "projection": {"name": "John"}
}'
```