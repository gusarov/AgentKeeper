$ErrorActionPreference = "Stop"
Write-Host "##vso[build.updatebuildnumber]$($Env:BUILD_BUILDNUMBER)_$($Env:AGENT_NAME)"

Get-Item -Path Env:*

docker --version
docker run --name hw hello-world
docker rm hw