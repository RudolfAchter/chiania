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
########################################################################
# PREPARE START
########################################################################
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


$a_collections=@(
    @{name="Chia Inventory"; folder_name="Chia_Inventory"; collection_id="col16fpva26fhdjp2echs3cr7c30gzl7qe67hu9grtsjcqldz354asjsyzp6wx"}
    @{name="Chreatures";     folder_name="Chreatures";     collection_id="col1w0h8kkkh37sfvmhqgd4rac0m0llw4mwl69n53033h94fezjp6jaq4pcd3g"}
    @{name="Brave Seedling"; folder_name="Brave_Seedling"; collection_id="col1jgw23rce22aucy0vrseqa3dte8sd0924sdjw5xuxzljcnhgr8fpqnjcu7q"}
    @{name="Sheesh! Snail";  folder_name="Sheesh__Snail";  collection_id="col1syclna803y6h3zl24fwswk0thmm7ad845cfc6sv4sndfzu26q8cq3pprct"}
    @{name="Chia Slimes";    folder_name="Chia_Slimes";    collection_id="col19z8k90wfezt55jj2zm526yzmk8dq0fcyqamzmtqv7hv4wkafhnjsp8fsz2"}
)
$collectionConfigFile=$configDir + "/" + "nft_collections.json"
if(-not (Test-Path $collectionConfigFile)){$a_collections | ConvertTo-Json -Depth 5 | Out-File $collectionConfigFile -Encoding UTF8}
$a_collections=Get-Content $collectionConfigFile -Encoding UTF8 | ConvertFrom-Json -Depth 5


$itemListFile=$configDir + "/" + "lists.data.json"
$itemListData=Get-Content $itemListFile -Encoding UTF8 | ConvertFrom-Json -Depth 5


$patterns=@(
    '(.*? Nuclei) ([a-zA-z].*?)([#0-9]+)',
    '()(.*?)([#0-9]+)'
)
#$specialItems=@('()(.*?)([#0-9]+)') #(Shadow Sword)','()(Brave Leef)')
$specialItems=@('()(Shadow Sword)','()(Brave Leef)')
$patterns+=$specialItems
$patternsFile=$configDir + "/" + "nft_name_patterns.json"
if(-not (Test-Path -Path $patternsFile)){$patterns | ConvertTo-Json | Out-File -FilePath $patternsfile -Encoding UTF8}
$patterns=Get-Content -Path $patternsFile -Encoding UTF8 | ConvertFrom-Json

#THESE ARE ONLY EXAMPLES!!! Configure in nft_type_patterns.json

$h_typePatterns=@{
    'Armor'  = @{
        patterns = @('.* Armor')
    }
    'Shield' = @{
        patterns = @('.* Shield')
    }
    'Herb'   = @{
        patterns = @('Brave Seedling','Brave Leef')
    }
    'Familiar' = @{
        patterns = @('snail','Chia Slime')
    }
    'Weapon' = @{
        patterns = @('Chiania Long Arm Blade','Catapult','Halberd','Khopesh','Knife','Sword','.* Axe','Axe',
                     '.* Bow','Bow','Stone','.* Club','Club','Enhanced Tree Root')
    }
    'Ring' = @{
        patterns = @('.* Ring','Ring')
    }
    'Mount'  = @{
        patterns = @('Deer')
    }
    'Collectable' = @{
        patterns = @('.* Monster Nuclei','Canned Slime')
    }
}

$typePatternsFile = $configDir + "/" + "nft_type_patterns.json"
if(-not (Test-Path $typePatternsFile)){$h_typePatterns | ConvertTo-Json -Depth 5 | Out-File -Path $typePatternsFile -Encoding UTF8}
$h_typePatterns=Get-Content -Path $typePatternsFile -Encoding UTF8 | ConvertFrom-Json -Depth 5


#Objects for MongoDB
#MongoDB Connection
$Server=$h_config.mongodb.server
$DatabaseName=$h_config.mongodb.database
$User=$h_config.mongodb.user
$Password=$h_config.mongodb.password

$connectionString="mongodb+srv://" + $User + ":" + $Password + "@" + $Server + "/" + $DatabaseName + "?retryWrites=true&w=majority"

Connect-Mdbc -ConnectionString $connectionString -DatabaseName $DatabaseName -CollectionName "items"


. ./ChianiaItemsFunctions.ps1

#################################################
# PREPARE END
#################################################

# Get Data from mintgarden
$i=0

$h_mgData=@{}

$a_collections | ForEach-Object {
    $coll=$_
    Write-Progress -Id 1 -Activity "Getting Mintgarden Data" -Status ("Collection " + $i + " of " + $a_collections.Count + " " + $coll.name) -PercentComplete ($i / $a_collections.Count * 100)
    $collData=Invoke-RestMethod -Uri ("https://api.mintgarden.io/collections/" + $coll.collection_id + "/nfts?size=100")
    $j=0
    do{
        Write-Progress -Id 1 -Activity "Getting Mintgarden Data" -Status ("Collection " + $i + " of " + $a_collections.Count + " " + $coll.name + " " + [string]($j*100) + " items.") -PercentComplete ($i / $a_collections.Count * 100)
        $pageStr=[System.Web.HttpUtility]::UrlEncode($collData.next)
        $collData=Invoke-RestMethod -Uri ("https://api.mintgarden.io/collections/" + $coll.collection_id + "/nfts?size=100&page="+$pageStr)
        
        ForEach($item in $collData.items){
            $h_mgData.Add($item.encoded_id,$item)
        }
        
        $j++
    }while($collData.next -ne $collData.page)
    $i++
}
Write-Progress -Id 1 -Activity "Getting Mintgarden Data" -Status ("Collection " + $i + " of " + $a_collections.Count) -Completed

# Get Data from Spacescan

$k=0
$totalData=$a_collections | ForEach-Object {
    $coll=$_
    #$collData=Invoke-RestMethod -Uri ("https://api2.spacescan.io/api/nft/collection/" + $coll.collection_id + "?x-auth-id=" + $h_config.spacescan.apiKey + "&coin=xch&page=1&count=40&version=1")
    $i=0
    $page=1
    $count=40
    $version=1

    Write-Progress -Id 1 -Activity "Getting Collection Data from SpaceScan" -Status ("collection " + ($k+1) + " of " + $a_collections.count) -PercentComplete (($k + 1)/ $a_collections.count * 100)
    do{
        $collData=Invoke-RestMethod -Uri ("https://api2.spacescan.io/api/nft/collection/" + $coll.collection_id + "?x-auth-id=" + $h_config.spacescan.apiKey + "&coin=xch&page=$page&count=$count&version=$version") -TimeoutSec 2
        $dat=$null
        if($collData.status -eq "success"){
            $collData.data | ForEach-Object {
                $dat=$_
                $collCount=$dat.count

                $pattern='.*?([0-9]+)'
                if($dat.meta_info.name -match $pattern){
                    $match=$dat.meta_info.name | Select-String -Pattern $pattern
                    [int]$itemNr=$match.Matches[0].Groups[1].Value
                }
                else{
                    [int]$itemNr=0
                }
                Add-Member -InputObject $dat.meta_info -MemberType NoteProperty -Name "nr" -Value $itemNr

                #Ausgabe
                Write-Progress -Id 2 -Activity "Getting NFTs from Collection" -Status ("NFT $i of " + $collCount + " : " + $dat.meta_info.name + " : " + $dat.nft_id) -PercentComplete ($i / $collcount * 100)
                Out-File -FilePath $logPath -InputObject ((Get-Date -Format "yyyy-MM-dd HH:mm:ss") + $dat.meta_info.name + ": " + $dat.nft_id + ": " + $i + " of " + $collCount) -Append
                $dat
                #zählen
                $i++
            }
        }
        else{
            Write-Warning("Error:" + ("https://api2.spacescan.io/api/nft/collection/" + $coll.collection_id + "?x-auth-id=" + $h_config.spacescan.apiKey + "&coin=xch&page=$page&count=$count&version=$version"))
            $i=$page * $count
            Write-Progress -Id 2 -Activity "Getting NFTs from Collection" -Status ("Nft $i of " + $collCount + " : ---") -PercentComplete ($i / $collcount * 100)
        }
        $page++
    }while($i -lt $collCount)
    Write-Progress -Id 2 -Activity "Getting NFTs from Collection" -Status ("NFT $i of " + $collCount + " : " + $dat.meta_info.name + " : " + $dat.nft_id) -Completed
    #}while($false)
    $k++
}
Write-Progress -Id 1 -Activity "Getting Collection Data from SpaceScan" -Status ("collection $k of " + $a_collections.count) -Completed





#Show Sorted Objects
#$totalData | ForEach-Object{Write-Host($_.meta_info.collection.name + " : " + $_.meta_info.nr + " : " + $_.meta_info.name)}

$i=1
#Powershell Objekte in Datenbank schreiben
$totalData | ForEach-Object {
    $item=$_
    $match=$null
    $itemName=$item.meta_info.name.Trim()


    Write-Progress -Id 1 -Activity "Combining Data and Writing to MongoDB" -Status ("NFT $i of " + $totalData.Count) -PercentComplete ($i/$totalData.Count*100)

    #TODO Run Get-ChiaNftInfo ONLY on FULLNODE!!
    #$nftInfo=Get-ChiaNftInfo -coin_ids "973d0f1d673dc90683576fb8722917acf401890b1eb2a7f54b6b85ee6f2ff1bd" 
    #TODO add NFT owner (DID-ID)
    #Mintgarden.io Search
    #$mtNftInfo=Invoke-RestMethod -Uri ("https://api.mintgarden.io/search?query=" + $item.nft_id)

    ForEach($pattern in $patterns){
        if($item.meta_info.name.Trim() -match $pattern){
            $match=Select-String -InputObject $item.meta_info.name.Trim() -Pattern $pattern
            [string]$prefix=$match.Matches[0].Groups[1].Value.Trim()
            [string]$itemType=$match.Matches[0].Groups[2].Value.Trim()
            #when Pattern has matched abort here
            break
        }
    }

    if($itemType.GetType().Name -ne "String"){
        Write-Warning("ItemType not String: " + $item.nft_id)
        #$itemType MUST be String!!! no clue why there sometimes comes a HashTable (WTF!)
        return
    }

    [string]$itemCategory=""
    ForEach($typePattern in $h_typePatterns.PSObject.Properties){
        ForEach($pattern in $typePattern.Value.patterns){
            if($item.meta_info.name -match $pattern){
                [string]$itemCategory=$typePattern.Name
                break
            }
        }
        if($itemCategory -ne ""){break}
    }
    if($itemCategory -eq ""){
        $itemCategory="Other"
    }

    if($prefix -eq ""){$prefix="Normal"}
    $stats=@{}

    #TODO get owner_hash from MintgardenData
    if($item.owner_hash -eq "000000000000000000000000000000000000000000000000000000000000dead"){
        $itemStatus="burned"
    }
    else{
        $itemStatus="active"
    }

    $nftId=$item.nft_id.Trim()

    #Die Encoded und decoded Dinger muss ich mit Cache machen
    $h_properties=[ordered]@{
        Name = $itemName
        Nr = $item.meta_info.nr
        ItemCategory = $itemCategory
        ItemType = $itemType
        ItemStatus = $itemStatus
        Prefix = $prefix
        Collection = $item.meta_info.collection.name.Trim()
        nft_id = $nftId
        #brauchen wir nicht. Kostet nur Performance
        #nft_id_decoded = ConvertTo-DecodedChiaAddress -string $item.nft_id.Trim() -prefix "nft"
        collection_id = $item.synthetic_id.Trim()
        item_uri = $item.nft_info.data_uris[0]
        attributes = $item.meta_info.attributes
        stats = $stats

        #Owner Info from Mintgarden
        owner_address_encoded_id = $h_mgData.$nftId.owner_address_encoded_id
        owner_encoded_id = $h_mgData.$nftId.owner_encoded_id
        creator_encoded_id = $h_mgData.$nftId.creator_encoded_id
        creator_address_encoded_id = $h_mgData.$nftId.creator_address_encoded_id
        creator_name=$h_mgData.$nftId.creator_name
        mintgarden_creator_verification_state=$h_mgData.$nftId.creator_verification_state
    }

    <#
    #Minter and Owner from SpaceScan
    if($null -ne $item.minter_did){
        $h_properties.minter_did = $item.minter_did.Trim()
        $h_properties.minter_did_encoded = ConvertTo-EncodedChiaAddress -prefix "did" -string $item.minter_did.Trim()
        $h_properties.minter_hash = $item.minter_hash.Trim()
    }

    if($null -ne $item.owner_did){
        $h_properties.owner_did= $item.owner_did.Trim()
        $h_properties.owner_did_encoded = ConvertTo-EncodedChiaAddress -prefix "did" -string $item.owner_did.Trim()
        $h_properties.owner_hash = $item.owner_hash.Trim()
    }
    #>


    $obj=[PSCustomObject]$h_properties

    #Set New Values for NFTs (if any)
    $mData=$null
    $mData=Get-MdbcData -Filter @{
            "nft_id" = $h_properties.nft_id
        }
    if($null -eq $mData){
        #Wenn Datensatz noch nicht existiert dann neu anlegen
        Set-MdbcData -Filter @{
            "nft_id" = $obj.nft_id
        } -Set $obj -Add
        #Ausgabe
        #$obj
    }
    else{
        $newData=[ordered]@{}
        #Write mdbcDictionary in Simple Hashtable
        ForEach($prop in $mData.GetEnumerator()){$newData.($prop.Key)=($prop.Value)}

        #Workaround Korrektur
        ForEach($prop in @("minter_did","minter_hash","owner_did","owner_hash","minter_did_encoded",
            "owner_did_encoded","owner_address_encoded")){$newData.Remove($prop)}

        #Wenn Datensatz schon existiert dann nur bestimmte Properties anpassen die sich ändern können (z.B. evtl Owner)
        ForEach($prop in @("ItemCategory","ItemType","Prefix","ItemStatus","item_uri"
            "owner_address_encoded_id","owner_encoded_id","creator_encoded_id","creator_encoded_id","creator_address_encoded_id",
            "creator_name","mintgarden_creator_verification_state"
        )){
            $newData.$prop=$obj.$prop
        }
        $newObj=[PSCustomObject]$newData


        Set-MdbcData -Filter @{
            "nft_id" = $obj.nft_id
        } -Set $newObj
        #Ausgabe
        #$newObj
    }

    $i++
}

Write-Progress -Id 1 -Activity "Combining Data and Writing to MongoDB" -Status ("NFT $i of " + $totalData.Count) -Completed




#$writtenItemObjects=$itemObjects 


