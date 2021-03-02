$ErrorActionPreference = "Stop"
Write-Host "##vso[build.updatebuildnumber]$($Env:Build_BuildId)_$($Env:AGENT_NAME)"

Get-Item -Path Env:*

docker --version
docker run --name hw hello-world
docker rm hw