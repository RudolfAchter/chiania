<#
ERLEDIGT Mintgarden api benutzen!
https://api.mintgarden.io/search?query=Chia+Inventory
col16fpva26fhdjp2echs3cr7c30gzl7qe67hu9grtsjcqldz354asjsyzp6wx
https://api.mintgarden.io/collections/col16fpva26fhdjp2echs3cr7c30gzl7qe67hu9grtsjcqldz354asjsyzp6wx/nfts?page=1&size=12

TODO Dexie.space Angebote holen
Beispiel: 
curl "https://dexie.space/v1/offers?offered=col1syclna803y6h3zl24fwswk0thmm7ad845cfc6sv4sndfzu26q8cq3pprct&requested=xch&page=1&page_size=50&sort=price_asc"
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

#Vertrannte Items müssen weg
#$totalData | Where-Object {$_.meta_info.name -like "Khopesh 01"} | Select-Object {$_.meta_info.name},{$_.owner_hash}

#Filter Out Burned Objects
$totalData=$totalData | Where-Object {$_.owner_hash -ne "000000000000000000000000000000000000000000000000000000000000dead"}

#Sort objects
$totalData=$totalData | Sort-Object -Property @({$_.meta_info.collection.name},{$_.meta_info.nr})

#Show Sorted Objects
#$totalData | ForEach-Object{Write-Host($_.meta_info.collection.name + " : " + $_.meta_info.nr + " : " + $_.meta_info.name)}

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



#Powershell Objekte erstellen
$itemObjects=$totalData | ForEach-Object {
    $item=$_
    $match=$null
    $itemName=$item.meta_info.name.Trim()

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
    $stats=@{
        slash  = @{val = 0;}
        bash   = @{val = 0;}
        pierce = @{val = 0;}
        magic  = @{val = 0;}
        defense  = @{val = 0;}
        str    = @{val = 0; scale=0}
        dex    = @{val = 0; scale=0}
        con    = @{val = 0; scale=0}
        cha    = @{val = 0; scale=0}
        wis    = @{val = 0; scale=0}
        luc    = @{val = 0; scale=0}
        health = @{val = 0; scale=0}
        spells = @()
    }
    
    Switch($itemType){
        "Knife" {
            $stats.slash.val = 1
            $stats.pierce.val = 1
            $stats.luc = @{ val = (Get-Random -Minimum 1 -Maximum 5); scale=1/5}
            $stats.dex = @{ val = (Get-Random -Minimum 1 -Maximum 5); scale=1/5}
            break
        }
        "Sword" {
            $stats.slash.val = 2
            $stats.bash.val = 1
            $stats.str = @{ val = (Get-Random -Minimum 1 -Maximum 5); scale=1/5}
            $stats.dex = @{ val = (Get-Random -Minimum 1 -Maximum 5); scale=1/5}
            break
        }
        "Short Axe" {
            $stats.slash.val = 2
            $stats.bash.val = 1
            $stats.str = @{ val = (Get-Random -Minimum 1 -Maximum 5); scale=1/5}
            $stats.dex = @{ val = (Get-Random -Minimum 1 -Maximum 5); scale=1/5}
            break
        }
        "Wood Club" {
            $stats.bash.val = 2
            $stats.str = @{ val = (Get-Random -Minimum 1 -Maximum 5); scale=1/5}
            $stats.dex = @{ val = (Get-Random -Minimum 1 -Maximum 5); scale=1/5}
            break
        }
        "Short Bow" {
            $stats.pierce.val = 2
            $stats.dex = @{ val = (Get-Random -Minimum 1 -Maximum 5); scale=1/6}
            break
        }
        "Catapult" {
            $stats.bash.val = 1
            $stats.str = @{ val = (Get-Random -Minimum 1 -Maximum 5); scale=1/6}
            $stats.con = @{ val = (Get-Random -Minimum 1 -Maximum 5); scale=1/6}
            break
        }
        "Enhanced Tree Root" {
            $stats.pierce.val = 1
            $stats.str = @{ val = (Get-Random -Minimum 1 -Maximum 5); scale=1/6}
            $stats.dex = @{ val = (Get-Random -Minimum 1 -Maximum 5); scale=1/6}
            break
        }
        "Khopesh" {
            $stats.bash.val = 1
            $stats.slash.val = 1
            $stats.pierce.val = 1
            $stats.str = @{ val = (Get-Random -Minimum 1 -Maximum 5); scale=1/8}
            $stats.dex = @{ val = (Get-Random -Minimum 1 -Maximum 5); scale=1/8}
            $stats.con = @{ val = (Get-Random -Minimum 1 -Maximum 5); scale=1/8}
            break
        }
        "Halberd" {
            $stats.slash.val = 1
            $stats.pierce.val = 2
            
            $stats.str = @{ val = (Get-Random -Minimum 1 -Maximum 5); scale=1/4}
            break
        }
        "Shadow Sword"{#Its cursed!
            $stats.slash.val = 5
            $stats.pierce.val = 1
            $stats.magic.val = 3
            $stats.str = @{ val = (Get-Random -Minimum 1 -Maximum 5); scale=-1/10}
            $stats.dex = @{ val = (Get-Random -Minimum 1 -Maximum 5); scale=-1/10}
            break
        }
        "Bark Shield"{
            $stats.defense = @{ val = 1; scale=1/5}
            break
        }
        "Cloth Armor"{
            #XXX Cloth Armor defense doesn' scale?
            $stats.defense = @{ val = 1}
            $stats.health  = @{ val = 1; scale=1/5}
            $stats.dex     = @{ val = (Get-Random -Minimum 1 -Maximum 5); scale=1/5}
            break
        }
        "Deer"{
            #XXX Deer doesn't scale?
            $stats.dex = (Get-Random -Minimum 1 -Maximum 5)
            
            #Majestic Deers
            $trait=$item.attributes | Where-Object{$_.trait_type -eq "Antlers"}
            if($trait.value -like "Majestic *"){
                $stats.str.val = (Get-Random -Minimum 1 -Maximum 5)
            }
            break
        }
        "Brave Seedling"{
            if($itemName -in $itemListData.Brave_Seedling_list){
                $stats.health.val = (Get-Random -Minimum 1 -Maximum 5)
            }
            if($itemName -in $itemListData.Powerful_Brave_Seedling_list){
                $stats.health.val = (Get-Random -Minimum 3 -Maximum 5)
            }
            if($itemName -in $itemListData.Super_Powerful_Brave_Seedling_list){
                $stats.health.val = (Get-Random -Minimum 3 -Maximum 5)
                #XXX Brave Seedling doesn't scale here?
                $stats.con.val = (Get-Random -Minimum 1 -Maximum 5)
            }
            break
        }
        "Chia Slime"{
            if($itemName -in $itemListData.Red_Chia_Slime_list){
                $stats.str.val = 1
                $stats.int.val = -1
            }
            elseif($itemName -in $itemListData.Blue_Chia_Slime_list){
                $stats.int.val = 1
                $stats.str.val = -1
            }
            elseif($itemName -in $itemListData.Green_Chia_Slime_list){
                $stats.dex.val = 1
                $stats.con.val = -1
            }
            elseif($itemName -in $itemListData.Orange_Chia_Slime_list){
                $stats.con.val = 1
                $stats.dex.val = -1
            }
            elseif($itemName -in $itemListData.Yellow_Chia_Slime_list){
                $stats.cha.val = 1
                $stats.wis.val = -1
            }
            elseif($itemName -in $itemListData.Yellow_Chia_Slime_list){
                $stats.wis.val = 1
                $stats.cha.val = -1
            }
            
            #These properties are ADDITIONAL
            if($itemName -in $itemListData.Healing_Chia_Slime_list){
                #TODO Spells on items are special. Need a way to interpret these Spell values in Code (that is has effect in Game)
                $stats.spells += @{
                    "name" = "heal"
                    "effect" = @{
                        "add_health"=@{
                            "chance" = 0.2
                            "min" = 2
                            "max" = 4
                        }
                    }
                }
            }

            if($itemName -in $itemListData.Identify_Chia_Slime_list){
                $stats.spells += @{
                    "name" = "identify"
                    "effect" = @{
                        "add_int"=@{
                            "chance" = 0.2
                            "min" = 2
                            "max" = 4
                        }
                    }
                }
            }
        }
        "snail" {
            if($itemName -in $itemListData.Snail_List){
                $stats.dex.val = -(Get-Random -Minimum 1 -Maximum 5)
                $stats.luc.val = +(Get-Random -Minimum 1 -Maximum 5)
            }
            if($itemName -in $itemListData.Hard_Snail_list){
                $stats.con.val = +(Get-Random -Minimum 1 -Maximum 5)
            }
        }
        "Chia Farmers" {
            if($itemName -in $itemListData.CeruleanBlueSkin_Chia_Farmers_List){
                $stats.int.val = 1
            }
            elseif($itemName -in $itemListData.CyanSkin_Chia_Farmers_List){
                $stats.con.val = 1
            }
            elseif($itemName -in $itemListData.DarkPurpleSkin_Chia_Farmers_List){
                $stats.cha.val = 1
            }
            elseif($itemName -in $itemListData.GoldSkin_Chia_Farmers_List){
                $stats.luc.val = 1
            }
            #XXX hier weiter mit Chia Farmers

        }


    }

    #Chia Inventory col16fpva26fhdjp2echs3cr7c30gzl7qe67hu9grtsjcqldz354asjsyzp6wx
    if($item.meta_info.collection.name.Trim() -eq "col16fpva26fhdjp2echs3cr7c30gzl7qe67hu9grtsjcqldz354asjsyzp6wx"){

        #Colored Nuclei built on Weapons or Items are Namedwith prefixes
        if($prefix -eq "Red Nuclei"){$stats.str+=(Get-Random -Minimum 1 -Maximum 5)}
        if($prefix -eq "Orange Nuclei"){$stats.con+=(Get-Random -Minimum 1 -Maximum 5)}
        if($prefix -eq "Green Nuclei"){$stats.dex+=(Get-Random -Minimum 1 -Maximum 5)}
        if($prefix -eq "Purple Nuclei"){$stats.wis+=(Get-Random -Minimum 1 -Maximum 5)}

        #Workaround for Nuclei Ring Names
        $itemName=$item.meta_info.name.Trim()
        if($itemName -eq "Nuclei Ring 01"){$stats.str=5}
        if($itemName -eq "Nuclei Ring 02"){$stats.dex=5}
        if($itemName -eq "Nuclei Ring 03"){$stats.int=5}
        if($itemName -eq "Nuclei Ring 04"){$stats.con=5}
        if($itemName -eq "Nuclei Ring 05"){$stats.wiz=5}
    }

    #TODO add NFT owner (DID-ID)

    [PSCustomObject]@{
        Name = $itemName
        Nr = $item.meta_info.nr
        ItemCategory = $itemCategory
        ItemType = $itemType
        Prefix = $prefix
        Collection = $item.meta_info.collection.name.Trim()
        nft_id = $item.nft_id.Trim()
        minter_did = $item.minter_did.Trim()
        minter_hash = $item.minter_hash.Trim()
        owner_did= $item.owner_did.Trim()
        owner_hash = $item.owner_hash.Trim()
        collection_id = $item.synthetic_id.Trim()
        item_uri = $item.nft_info.data_uris[0]
        attributes = $item.meta_info.attributes
        stats = $stats
    }
}

Connect-Mdbc -ConnectionString $connectionString -DatabaseName $DatabaseName -CollectionName "items"


#Set New Values for NFTs (if any)
$writtenItemObjects=$itemObjects | ForEach-Object {
    Get-MdbcData -Filter @{
            "nft_id" = $_.nft_id
        }`
        -Set $_
}


