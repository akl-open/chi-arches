# pass in your docker username as a param. run as ./push-az-img.ps1 -usr "smith" -pwd "1234"
param([string]$usr = "", [string]$pwd = "")
docker login aklopendev.azurecr.io -u $usr -p $pwd
docker tag aklopendev.azurecr.io/akarches aklopendev.azurecr.io/akarches:4.3.1-01
docker push aklopendev.azurecr.io/akarches