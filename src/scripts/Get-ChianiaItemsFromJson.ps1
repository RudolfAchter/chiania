$configDir="~/git/chiania/config"
$dataDir="~/git/chiania/data"
$itemsDir="~/git/chiania/docs/items/Types"
$logPath="~/Documents/chiania_items.log"


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


############################
#Functions
#########################

Function Render-ChianiaNft {
    param($nft)

    $out+='<div class="item_thumbnail">' + "`r`n"
    $out+='<a href="https://mintgarden.io/nfts/' + $nft.nft_id + '"><img loading="lazy" src="' + $nft.icon + '"></a>' + "`r`n"
    $out += '<div><strong>' + "Name" + ':</strong><a href="https://mintgarden.io/nfts/' + $nft.nft_id + '">' + $nft.item_name + '</a></div>' + "`r`n"
    $out += '<div><strong>' + "Item Type" + ':</strong> ' + $nft.item_type + '</div>' + "`r`n"
    #$out += '<div><strong>' + "Collection" + ':</strong> <a href="https://mintgarden.io/collections/' + $nft.collection_id +'">' + $nft.collection_id + '</a></div>' + "`r`n"
    
    #On Chain Attributes
    if(($nft."on-chain-attributes".PsObject.Properties.Value | Measure-Object).Count -gt 0){
        #$out += '<div><strong>On Chain Attributes</strong></div>' + "`r`n"
        ForEach ($attr in $nft."on-chain-attributes".PsObject.Properties.Value){
                $out += '<div><strong>' + $attr.trait_type + ':</strong> ' + $attr.value + '</div>' + "`r`n"
        }
        $out += '<div><strong>//</strong></div>'
    }

    #In Game Attributes
    ForEach ($attr in $nft."in-game-attributes".PsObject.Properties.Value){
        $out += '<div><strong>' + $attr.type + ':</strong> '# + $attr.value + '</div>' + "`r`n"
        if($null -ne $attr.factor){$out+=$attr.factor + ": "}
        if($null -ne $attr.value) {$out+=$attr.value }
        $out += '</div>' + "`r`n"
    }
    $out+='</div>' + "`r`n"
    $out
}


$o_itemsDir=Get-Item -Path $itemsDir

# Empty Items Dir in Before
Get-ChildItem $o_itemsDir | Remove-Item -Recurse -Force -Confirm:$false

$data=Get-Content ($dataDir + "/new_item_list.json") | ConvertFrom-Json
$nftArray=$data.PsObject.Properties.Value

$nftArray=$nftArray | ForEach-Object {
    $dat=$_
    #Nr Values ergänzen
    $pattern='.*?([0-9]+)'
    if($dat.item_name -match $pattern){
        $match=$dat.item_name | Select-String -Pattern $pattern
        [int]$itemNr=$match.Matches[0].Groups[1].Value
    }
    else{
        [int]$itemNr=-1
    }
    Add-Member -InputObject $dat -MemberType NoteProperty -Name "item_nr" -Value $itemNr
    $dat
}

$dateStr=Get-Date -Format "yyyy-MM-dd"

$idxout=@"
# Items Categories

"@
$idxout+="`r`n"


$nftArray | Group-Object item_type | ForEach-Object {
    $typeGroup=$_
    $typeName=$typeGroup.Name
    $idxout += "- [" + $typeGroup.Name + "](" + $typeGroup.Name + "/README.md)" + "`r`n"
    
    $typeGroupOut= @"
# Collections

"@
    $typeGroupOut+="`r`n"

    if(-not (Test-Path($o_itemsDir.FullName + "/" + $typeGroup.Name))){
        New-Item -ItemType Directory -Path ($o_itemsDir.FullName + "/" + $typeGroup.Name)
    }


    $typeGroup.Group | Group-Object collection_name | ForEach-Object {
        $collectionGroup=$_
        $collectionGroup = $collectionGroup | Sort-Object -Property "item_name"
        $collectionDirName=$collectionGroup.Name -replace '[^a-zA-Z0-9]',"_"
        $typeGroupOut+= "- [" + $collectionGroup.Name + "](" + $collectionDirName + "/01.md)" + "`r`n"
        $collectionDirPath=($o_itemsDir.FullName + "/" + $typeGroup.Name + "/" + $collectionDirName)
        $collectionName=$collectionGroup.Name
        
        if(-not (Test-Path $collectionDirPath)){
            New-Item -ItemType Directory -Path $collectionDirPath
        }

        $page=1
        $i=0
        $end=$i+$itemsPerPage
        $pagestr = "{0:d2}" -f $page
        
        $out=@"
# $typeName - $collectionName - $pagestr

"@
        $out+="`r`n"

        $out += "Collection [" + $collectionName + " - " + $collectionGroup.Group[0].collection_id
        $out += "](https://mintgarden.io/collections/" + $collectionGroup.Group[0].collection_id  + ")"

        while($i -lt $collectionGroup.Count){
            if($i -ge $end){
                $out | Out-File -Path ($collectionDirPath + "/" + $pagestr + ".md")
                $page++
                $pagestr = "{0:d2}" -f $page
                $end=$i+$itemsPerPage
                $out=@"
                # $typeName - $collectionName - $pagestr

"@
                $out+="`r`n"
                $out += "Collection [" + $collectionName + " - " + $collectionGroup.Group[0].collection_id
                $out += "](https://mintgarden.io/collections/" + $collectionGroup.Group[0].collection_id  + ")"
        
            }
            $collectionGroup.Group[$i] | Add-Member -MemberType NoteProperty -Name Page -Value $page -Force
            #$collectionGroup.Group[$i] | Select-Object "Page","item_name"
            $out+=Render-ChianiaNft -nft $collectionGroup.Group[$i]
            $i++
        }
        #Flush the rest
        $out | Out-File -Path ($collectionDirPath + "/" + $pagestr + ".md")
    }

    $typeGroupOut | Out-File -Path ($o_itemsDir.FullName + "/" + $typeGroup.Name  + "/README.md")
    

}

$idxout | Out-File -Path ($o_itemsDir.FullName + "/README.md")