
#$Global:ChiaShell
#$srcDir="~/git/chiania/src"
$configDir="~/git/chiania/config"
$itemsDir="~/git/chiania/docs/items"
$logPath="~/Documents/chiania_items.log"

$scriptConfigFile=$configDir + "/" + "scriptConfig.json"
$h_config=Get-Content -Path $scriptConfigFile -Encoding UTF8 | ConvertFrom-Json -Depth 10


$Server=$h_config.mongodb.server
$Database=$h_config.mongodb.database
$User=$h_config.mongodb.user
$Password=$h_config.mongodb.password

$connectionString="mongodb+srv://" + $User + ":" + $Password + "@" + $Server + "/" + $Database + "?retryWrites=true&w=majority"

Connect-Mdbc -ConnectionString $connectionString -DatabaseName "chia-stuff" -CollectionName "test"

@{_id = 1; value = 42}, @{_id = 2; value = 3.14} | Add-MdbcData

Get-MdbcData -As PS | Format-Table

# Connect the new collection test.test

#Add-Type -Path "~/.config/MongoDB.Driver.2.17.1/lib/net472/MongoDB.Driver.dll"
#Add-Type -Path "~/.config/MongoDB.Bson.2.17.1/lib/net472/MongoDB.Bson.dll"

#$mongoClient=[MongoDB.Driver.MongoClient]




# Add some test data
@{_id=1; value=42}, @{_id=2; value=3.14} | Add-MdbcData

# Get all data as custom objects and show them in a table
Get-MdbcData -As PS | Format-Table -AutoSize | Out-String