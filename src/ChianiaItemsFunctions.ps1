$argumentCompleters=@{
    "AddressType"={
        param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameters)
        $global:ChiaShell.AddressType.GetEnumerator() | Where-Object {$_.Name -like ($wordToComplete+"*")} | ForEach-Object {
            '"' + $_.Name + '"' + ' <#' + $_.Value + '#>'
        }
    }
}


$global:chiaHashMap=@{
    "xch"=@{}
    "nft"=@{}
    "did"=@{}
}


Function ConvertTo-DecodedChiaAddress {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        $string,
        [Parameter(Mandatory=$true)]
        $prefix
    )

    #Memory Cache
    if($null -ne $global:chiaHashMap.$prefix.$string){
        $global:chiaHashMap.$prefix.$string
        return
    }


    #Cache With MongoDB
    $mColl=$null
    $mColl=(Get-MdbcCollection -Name ("hash_map_"+$prefix))
    $result=Get-MdbcData -Filter @{"encoded"=$string} -Collection $mColl
    if($null -eq $result){
        $decodedString=cdv decode $string
        $entry=[PSCustomObject]@{
            hash = $decodedString
            encoded = $string
        }
        Add-MdbcData -InputObject $entry -Collection $mColl
        $decodedString
    }
    else{
        $result.hash
    }

    $global:chiaHashMap.$prefix.$string=$decodedString
    $global:chiaHashMap.$prefix.$decodedString=$string
}

Function ConvertTo-EncodedChiaAddress {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        $string,
        [Parameter(Mandatory=$true)]
        $prefix
    )

    #Memory Cache
    if($null -ne $global:chiaHashMap.$prefix.$string){
        $global:chiaHashMap.$prefix.$string
        return
    }

    #MongoDb Cache
    $mColl=$null
    $mColl=(Get-MdbcCollection -Name ("hash_map_"+$prefix))
    $result=Get-MdbcData -Filter @{"hash"=$string} -Collection $mColl
    
    if($null -eq $result){
        $encodedString=cdv encode --prefix $global:ChiaShell.AddressType.$prefix $string
        $entry=[PSCustomObject]@{
            hash = $string
            encoded = $encodedString
        }
        Add-MdbcData -InputObject $entry -Collection $mColl
        $encodedString
    }
    else{
        $result.encoded
    }

    $global:chiaHashMap.$prefix.$string=$encodedString
    $global:chiaHashMap.$prefix.$encodedString=$string
}


Function Out-MobileObject {
    param(
        [Parameter(ValueFromPipeline=$true)]
        $mob
    )

    Begin{
        $h_name_map=@{
            "name"="Name"
            "health"="Health"
            "attack"="attack"
            "slash_defense"="Slash Defense"
            "bash_defense"="Bash Defense"
            "pierce_defense"="Pierce Defense"
            "description"="Description"
            "author"="Author"
        }
    }

    Process{
        $mob | ForEach-Object {
            $m=$_
            $out=''
            $out+='<div class="monster_thumbnail">' + "`r`n"
            $out+='<img src="../../../include/chiania-mimic.png">'
            foreach($val in @("name","health","attack","slash_defense","bash_defense","pierce_defense")){
                $out+='<div><strong>'+ $h_name_map.$val +':</strong> ' + [System.Web.HttpUtility]::HtmlEncode($m.$val) + '</div>'+ "`r`n"
            }
            #"description","author"
            $out+='<div style="clear:left;"><strong>Description:</strong> ' + $m.description + '</div>'
            $out+='</div>' + "`r`n"
            $out
        }
    }

    End{}

}


Register-ArgumentCompleter -CommandName ConvertTo-EncodedChiaAddress -ParameterName "prefix" -ScriptBlock $argumentCompleters.AddressType
Register-ArgumentCompleter -CommandName ConvertTo-DecodedChiaAddress -ParameterName "prefix" -ScriptBlock $argumentCompleters.AddressType