# pass in your docker username as a param. run as ./push-img.ps1 -usr "smith"
param([string]$usr = "")
docker login --username $usr

docker tag aklopen/chiarches aklopen/chiarches:4.3.1-01

docker push aklopen/chiarches