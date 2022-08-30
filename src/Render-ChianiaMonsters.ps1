#$srcDir="~/git/chiania/src"
$configDir="~/git/chiania/config"
$monstersFilePath="~/git/chiania/docs/world/monsters/01_monsters.md"
$dataDir="~/git/chiania/data"
$logPath="~/Documents/chiania_items.log"

. ./ChianiaItemsFunctions.ps1

$srcFile=Get-Item -Path ($dataDir + "/mobile_object.json")

$mobileObjects=Get-Content -Path $srcFile.FullName -Encoding UTF8 | ConvertFrom-Json

$array=@()
$mobileObjects.PsObject.Properties | ForEach-Object {
    $array+=$_.Value
}



$out=@'
---
title: Monsters
description: Monsters and creatures in the world of chiania
date: 2022-08-29
tags:
  - Chia
  - Game
  - NFT
  - Monster
---

# Monsters

'@

$out+="`r`n`r`n"
$out+=$array | Where-Object type -eq "monster" | Out-MobileObject

$out | Out-File -FilePath $monstersFilePath


