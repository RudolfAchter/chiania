Import-Module -Name "Mdbc"

$Global:ChiaShell

#$srcDir="~/git/chiania/src"
$configDir="~/git/chiania/config"
$itemsDir="~/git/chiania/docs/items"
$dataDir="~/git/chiania/data"
$logPath="~/Documents/chiania_items.log"
$scriptConfigFile=$configDir + "/" + "scriptConfig.json"

#Write default Json File if there isn't one already
#I always load from json File to always Get the same result
$h_config=Get-Content -Path $scriptConfigFile -Encoding UTF8 | ConvertFrom-Json -Depth 10

$Server=$h_config.mongodb.server
$DatabaseName=$h_config.mongodb.database
$User=$h_config.mongodb.user
$Password=$h_config.mongodb.password

$connectionString="mongodb+srv://" + $User + ":" + $Password + "@" + $Server + "/" + $DatabaseName + "?retryWrites=true&w=majority"

mongoexport --uri $connectionString --collection "items" --type JSON --out ($dataDir + "/" + "items.json")