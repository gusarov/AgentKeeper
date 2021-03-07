$ErrorActionPreference = "Stop"
[string] $global:buildNumber = ''

function AppendBuildNumber([string] $data) {
	$global:buildNumber += "_" + $data;
	Write-Host "#vso[build.updatebuildnumber]$($Env:BUILD_BUILDNUMBER)$buildNumber"
	Write-Host "##vso[build.updatebuildnumber]$($Env:BUILD_BUILDNUMBER)$buildNumber"
	Start-Sleep 5
}

#Write-Host "##vso[build.updatebuildnumber]$($Env:BUILD_ID)_$($Env:AGENT_NAME)"
AppendBuildNumber($Env:AGENT_OS + "_" + $Env:AGENT_NAME)

$linOrWin = $Env:AGENT_OS -eq 'Linux'

Get-Item -Path Env:* | Sort-Object -Property Name | FT

$permissionMarker = '/_PermissionMarker'
<#
if ($linOrWin) {
	$permissionMarker = '/_PermissionMarker'
} else {
	$permissionMarker = 'C:\_PermissionMarker'
}
#>

$traceMarker = '_TraceMarker'
$rule1 = 'Rule #1 - either ephemeral admins or permanent users'

#1 Priveledged Permanent?
if (Test-Path $permissionMarker) {
	throw "This agent is reused after pipeline with full premissions. $rule1"
}

Write-Host "Creating $permissionMarker"
try {
	New-Item -ItemType directory $permissionMarker
	Write-Host "Success"
} catch {
	Write-Host "An error occurred:"
	Write-Host $_
}

if ($linOrWin) {
	# need to test per-comand elevation as well, sudo is needed even if agent works wihtout it
	try {
		sudo mkdir $permissionMarker
		Write-Host "Sudo Success"
	} catch {
		# may be not access, may be no sudo
		Write-Host "A sudo error occurred:"
		Write-Host $_
	}
}

if (Test-Path $permissionMarker) {
	Write-Host "Marker Exists"
	AppendBuildNumber('ADMIN')
} else {
	Write-Host "Marker Not Found"
	AppendBuildNumber('USER')
}

# docker must be installed and accessible
docker --version
docker run --name hw hello-world
docker rm hw
docker-compose --version
docker compose

# node must be installed
node --version
npm --version

# zip
#zip
