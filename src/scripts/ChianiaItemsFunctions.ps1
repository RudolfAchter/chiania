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


Register-ArgumentCompleter -CommandName ConvertTo-EncodedChiaAddress -ParameterName "prefix" -ScriptBlock $argumentCompleters.AddressType
Register-ArgumentCompleter -CommandName ConvertTo-DecodedChiaAddress -ParameterName "prefix" -ScriptBlock $argumentCompleters.AddressType