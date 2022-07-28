#!/bin/bash

cd ~/git/chiania
git pull

pwsh ~/git/ChiaShell/Powershell/Scripts/Get-ChianiaItems_V3.ps1

mkdocs build
git add .
git commit -a -m "Inventory refresh"
git push