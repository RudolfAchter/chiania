git add .
git commit -m "publish"
git pull
pwsh ./src/Get-ChianiaItems_V4.ps1
mkdocs build
git add .
git commit -m "publish"
git push

