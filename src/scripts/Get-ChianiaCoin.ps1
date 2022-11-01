<#
TODO Dexie.space Angebote holen
Beispiel: 
curl "https://dexie.space/v1/offers?offered=col1syclna803y6h3zl24fwswk0thmm7ad845cfc6sv4sndfzu26q8cq3pprct&requested=xch&page=1&page_size=50&sort=price_asc"

I use chia-dev-tools for encoding and decoding puzzle hashes
https://github.com/Chia-Network/chia-dev-tools

```bash
pip install chia-dev-tools


cdv encode --prefix "did:chia:" $item.owner_did

cdv encode für ALLE Datensätze zu machen ist zu langsam stattdessen bei Query sowas hier machen

cdv decode did:chia:1cl7p3apyphluqwn4scndes6rpky35pn8stcr0fzg4hhug3wfas9s6t30kw

```
#>
Import-Module -Name "Mdbc"

$Global:ChiaShell

#$srcDir="~/git/chiania/src"
$configDir="~/git/chiania/config"
$itemsDir="~/git/chiania/docs/items"
$logPath="~/Documents/chiania_items.log"
#$outFile="items_test2.md"
#$replaceFile=($chianiaDir + "/" + $outFile)

if(-not (Test-Path ($configDir))){
    New-Item -Path $ConfigDir -ItemType Directory
}

$h_config=@{
    "spacescan" = @{
        apiKey="yourApiKey"
    }
}
$itemsPerPage=100

$scriptConfigFile=$configDir + "/" + "scriptConfig.json"

#Write default Json File if there isn't one already
if(-not (Test-Path ($scriptConfigFile))){
    $h_config | ConvertTo-Json -Depth 10 | Out-File -Path $scriptConfigFile -Encoding UTF8
}

#I always load from json File to always Get the same result
$h_config=Get-Content -Path $scriptConfigFile -Encoding UTF8 | ConvertFrom-Json -Depth 10

$i=0
$page=1
$count=40
$version=1

#api/nft/collection/
$data=Invoke-RestMethod -Uri ("https://api2.spacescan.io/v0.1/xch/cat/446f5c3532929f71fa82f1c65f7e93170dcfbf8d59baf82a81b6f8e8f85e8a5c") -TimeoutSec 2

$data=Invoke-RestMethod -Uri ("https://api2.spacescan.io/v0.1/xch/cats")


$data=Invoke-RestMethod -Uri("https://api2.spacescan.io/1/xch/token/transactions/446f5c3532929f71fa82f1c65f7e93170dcfbf8d59baf82a81b6f8e8f85e8a5c/CAT2?count=50&page=1")

$data.tokens | ForEach-Object {
    $token=$_
    # For `cdv` command you need chia dev tools: https://github.com/Chia-Network/chia-dev-tools
    $fromAddress=cdv encode $token.from_puzzle_hash --prefix "xch"
    $toAddress=cdv encode $token.puzzle_hash --prefix "xch"
    [PSCustomObject]@{
        Date = ([timezone]::CurrentTimeZone.ToLocalTime(([datetime]'1/1/1970').AddSeconds($token.timestamp)))
        fromAddress = $fromAddress
        toAddress = $toAddress
        amount=$token.amount
    }

} | Format-List