<#
ERLEDIGT Mintgarden api benutzen!
https://api.mintgarden.io/search?query=Chia+Inventory
col16fpva26fhdjp2echs3cr7c30gzl7qe67hu9grtsjcqldz354asjsyzp6wx
https://api.mintgarden.io/collections/col16fpva26fhdjp2echs3cr7c30gzl7qe67hu9grtsjcqldz354asjsyzp6wx/nfts?page=1&size=12

TODO Dexie.space Angebote holen
Beispiel: 
curl "https://dexie.space/v1/offers?offered=col1syclna803y6h3zl24fwswk0thmm7ad845cfc6sv4sndfzu26q8cq3pprct&requested=xch&page=1&page_size=50&sort=price_asc"
#>

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

#traitPatterns by Collection
$h_traitPrefixGroups=@{
    "Chia Mounts"=@{
        trait = "Species"
        pattern = "(.*)"
    }
    "Chreatures"=@{
        trait = "Antlers"
        pattern = "(^[A-Za-z0-9]+)"
    }
    "Chia Slimes"=@{
        trait = "Drop Set"
        pattern = "(.*)"
    }
}


$itemList=[ordered]@{}

#Powershell Objekte erstellen
$totalData | ForEach-Object {
    $item=$_

    if($null -eq $itemList.($item.nft_id)){
        $match=$null

        $match=$null
        ForEach($pattern in $patterns){
            if($item.meta_info.name.Trim() -match $pattern){
                $match=Select-String -InputObject $item.meta_info.name.Trim() -Pattern $pattern
                [string]$prefix=$match.Matches[0].Groups[1].Value.Trim()
                [string]$itemType=$match.Matches[0].Groups[2].Value.Trim()
                #when Pattern has matched abort here
                break
            }
        }

        #Prefix by Trait
        if($null -ne $h_traitPrefixGroups.($item.meta_info.collection.name)){
            $traitValue=($item.meta_info.attributes | Where-Object{$_.trait_type -eq $h_traitPrefixGroups.($item.meta_info.collection.name).trait}).value
            $match=Select-String -InputObject $traitValue -Pattern $h_traitPrefixGroups.($item.meta_info.collection.name).pattern
            $prefix=$match.Matches[0].Groups[1].Value.Trim()
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
        
        Try{
            #build JSON Tree (as Powershell HashTables)
            if($null -eq $itemList.($itemCategory)){$itemList.Add($itemCategory,[ordered]@{})}
            if($null -eq $itemList.($itemCategory).($itemType)){$itemList.($itemCategory).Add($itemType,[ordered]@{})}
            if($null -eq $itemList.($itemCategory).($itemType).($prefix)){$itemList.($itemCategory).($itemType).Add($prefix,[ordered]@{})}
            if($null -eq $itemList.($itemCategory).($itemType).($prefix).($item.nft_id)){
                $itemList.($itemCategory).($itemType).($prefix).Add($item.nft_id,[PSCustomObject]@{
                    Name = $item.meta_info.name.Trim()
                    Nr = $item.meta_info.nr
                    ItemCategory = $itemCategory
                    ItemType = $itemType
                    Prefix = $prefix
                    Collection = $item.meta_info.collection.name.Trim()
                    nft_id = $item.nft_id.Trim()
                    minter_did = $item.minter_did.Trim()
                    collection_id = $item.synthetic_id.Trim()
                    item_uri = $item.nft_info.data_uris[0]
                    attributes = $item.meta_info.attributes
                })
            }
            else{
                
            }
        }Catch{
            Write-Warning("Error Adding ItemType or Adding Item: '" + $item.nft_id + "'")
        }
    }
}

$itemList.GetEnumerator()

<#
$itemList.GetEnumerator() | ForEach-Object {
    $_.Value.GetEnumerator() | ForEach-Object{
        $_.Value.Name
    }
} | Select-Object -First 100
#>

$itemList | ConvertTo-Json -Depth 7 | Out-File -Path ($itemsDir + "/" + "ChianiaItems.groupByItemType.json") -Encoding UTF8



#Markdown / HTML Output

Get-ChildItem -Path ($itemsDir + "/Types/") -Directory | Remove-Item -Recurse -Force -Confirm:$false

#ItemTypes

$curDate=Get-Date -Format "yyyy-MM-dd"


$itemList.GetEnumerator() | Sort-Object Name | ForEach-Object {

    $o_itemCategory=$_
    $itemCategoryName=$o_itemCategory.Name

    $out=@"
---
title: Category - $itemCategoryName
description: Item Types in Chia Inventory
date: $curDate
tags:
    - NFT
    - Items
---

# Category - $itemCategoryName

"@

    $o_itemCategory.Value.GetEnumerator() | Sort-Object Name | ForEach-Object{
        $o_itemType=$_
        #Render First Item of Each itemType for Preview
        $o_itemType.Value.GetEnumerator() | Select-Object -Last 1 | ForEach-Object{
            $o_itemPrefix=$_
            $o_itemPrefix.Value.GetEnumerator() | Select-Object -Last 1 | ForEach-Object{
                $indexItem=$_.Value
                $itemStart=1
                $itemEnd=$itemStart + ($itemsPerPage - 1)
                $firstItemLink = '../../Types/'+ $itemCategoryName + '/' + ($indexItem.ItemType -replace '[^A-Za-zäöüÄÖÜ\-_]','_')+ "/"+ 
                    ($o_itemPrefix.Name  -replace '[^A-Za-zäöüÄÖÜ\-_]','_') + "_" + ($indexItem.ItemType -replace '[^A-Za-zäöüÄÖÜ\-_]','_') + "_" +
                    ("{0:d5}" -f $itemStart) + "_" + ("{0:d5}" -f $itemEnd) + "/"
                $out+='<div class="item_type_thumbnail">' + "`r`n"
                $out+='<a href="' + $firstItemLink + '"><img loading="lazy" src="' + $indexItem.item_uri + '"></a><br/>' + "`r`n"
                $out += '<div><strong>' + "Item Type" + ':</strong> <a href="' + $firstItemLink  + '">' + $indexItem.ItemType + '</a></div>' + "`r`n"
                $out += '<div><strong>' + "Collection" + ':</strong> <a href="https://www.spacescan.io/xch/nft/collection/' + $indexItem.collection_id +'">' + $indexItem.Collection + '</a></div>' + "`r`n"
                <#
                ForEach ($attr in $indexItem.attributes){
                        $out += '<div><strong>' + $attr.trait_type + ':</strong> ' + $attr.value + '</div>' + "`r`n"
                }
                #>
                $out+='</div>' + "`r`n"        
            }
        }
    }

    $itemsPath=($itemsDir + "/Types/" + ($itemCategoryName -replace '[^A-Za-zäöüÄÖÜ\-_]','_'))

    if(-not (Test-Path $itemsPath)){
        New-Item -Path $itemsPath -ItemType Directory | Out-Null
    }

    $out | Out-File -FilePath ($itemsPath + "/README.md")

}

#ItemType Indexes
$i=0

$itemCategoryCount=($itemList.GetEnumerator() | Measure-Object).Count

$itemList.GetEnumerator() | ForEach-Object {
    $o_itemCategory=$_
    $itemCategoryName=$o_itemCategory.Name

    Write-Progress -Id 1 -Activity "Writing Item Categories" -Status "$i of $itemCategoryCount" -PercentComplete ($i / $itemCategoryCount * 100)

    $o_itemCategory.Value.GetEnumerator() | ForEach-Object {

        $o_itemType=$_
        $itemTypeName=$o_itemType.Name


        $itemTypePath=($itemsDir + "/Types/"+ ($itemCategoryName -replace '[^A-Za-zäöüÄÖÜ\-_]','_') + "/" + ($o_itemType.Name -replace '[^A-Za-zäöüÄÖÜ\-_]','_'))

        if(-not (Test-Path $itemTypePath)){
            New-Item -Path $itemTypePath -ItemType Directory | Out-Null
        }

        $itemTypeCount=($o_itemType.Value.GetEnumerator() | Measure-Object).Count

        
        $j=0
        $o_itemType.Value.GetEnumerator() | ForEach-Object{
            $o_itemPrefix=$_
            $itemPrefixName=$o_itemPrefix.Name
            $newItemPrefix=$true
            $indexItemCount=($o_itemPrefix.Value.GetEnumerator() | Measure-Object).Count
            $k=0
            $itemStart=$k+1
            $itemEnd=$k+$itemsPerPage

            Write-Host($itemTypeName + ":" + $itemPrefixName + " Items $itemStart - $itemEnd")

            #Render All Items
            $o_itemPrefix.Value.GetEnumerator() | ForEach-Object{
                $indexItem=$_.Value


                $out_prefix=@"
---
title: $itemTypeName - $itemPrefixName ($itemStart - $itemEnd)
description: $itemTypeName Items in Chia Inventory
date: $curDate
tags:
    - NFT
    - Items
---

# $itemTypeName - $itemPrefixName ($itemStart - $itemEnd)

"@
                #Flush Out Buffer when there are enough Items
                if($k -ge $itemEnd -or $newItemPrefix){
                    $newItemPrefix=$false
                    $out=$out_prefix + $out
                    $out | Out-File -FilePath ($itemTypePath + "/" + ($itemPrefixName -replace '[^A-Za-zäöüÄÖÜ\-_]','_') + "_" + ($indexItem.ItemType -replace '[^A-Za-zäöüÄÖÜ\-_]','_') + "_" + 
                        ("{0:d5}" -f $itemStart) + "_" + ("{0:d5}" -f $itemEnd) + ".md")

                    $itemStart=$k+1
                    $itemEnd=$k+$itemsPerPage
                    $out=""
                }

                #$out+="## " + $o_itemPrefix.Name + "`r`n`r`n"

                Write-Progress -Id 2 -Activity "Writing Items" -Status ("$k of $indexItemCount") -PercentComplete ($k / $indexItemCount * 100)
                $out+='<div class="item_thumbnail">' + "`r`n"
                $out+='<img loading="lazy" src="' + $indexItem.item_uri + '"><br/>' + "`r`n"
                $out += '<div><strong>' + "Name" + ':</strong> ' + $indexItem.Name + '</div>' + "`r`n"
                $out += '<div><strong>' + "Item Type" + ':</strong> ' + $indexItem.ItemType + '</div>' + "`r`n"
                $out += '<div><strong>' + "Collection" + ':</strong> <a href="https://www.spacescan.io/xch/nft/collection/' + $indexItem.collection_id +'">' + $indexItem.Collection + '</a></div>' + "`r`n"
                
                ForEach ($attr in $indexItem.attributes){
                        $out += '<div><strong>' + $attr.trait_type + ':</strong> ' + $attr.value + '</div>' + "`r`n"
                }

                $out+='</div>' + "`r`n"



                $k++
            }

            #Flush Out Rest

            $newItemPrefix=$false
            $out=$out_prefix + $out
            $out | Out-File -FilePath ($itemTypePath + "/" + ($itemPrefixName -replace '[^A-Za-zäöüÄÖÜ\-_]','_') + "_" + ($indexItem.ItemType -replace '[^A-Za-zäöüÄÖÜ\-_]','_') + "_" + 
                ("{0:d5}" -f $itemStart) + "_" + ("{0:d5}" -f $itemEnd) + ".md")

            $itemStart=$k+1
            $itemEnd=$k+$itemsPerPage
            $out=""

            Write-Progress -Id 2 -Activity "Writing Items" -Status ("$k of $indexItemCount") -Completed
            #$out+='<hr style="clear:both;"/>' + "`r`n"
            $j++
        }

        #$out | Out-File -FilePath ($itemTypePath + "/" + ($indexItem.ItemType -replace '[^A-Za-zäöüÄÖÜ\-_]','_') + ".md")
    }
    $i++
}

Write-Progress -Id 1 -Activity "Writing Item Categories" -Status "$i of $itemCategoryCount" -Completed