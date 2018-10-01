# pass in your docker username as a param. run as ./push-img.ps1 -usr "smith"
param([string]$usr = "")
docker login --username $usr
docker push aklopen/akarches:latest