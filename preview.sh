git add .
git commit -m "preview"
git pull
pwsh ./src/scripts/Get-ChianiaItems_V4.ps1
git add .
git commit -m "preview"
mkdocs serve

