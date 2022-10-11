git add .
git commit -m "publish"
git pull
pwsh ./src/scripts/Get-ChianiaItemsFromJson.ps1
mkdocs build
git add .
git commit -m "publish"
git push
#Want to see it again
if [ "$1" == "serve" ];then
    mkdocs serve
fi
