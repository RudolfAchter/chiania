#!/bin/bash

pwsh ~/git/ChiaShell/Powershell/Scripts/Get-ChianiaItems_V3.ps1
cd ~/git/chiania
mkdocs build
git commit -a -m "Inventory refresh"
git push