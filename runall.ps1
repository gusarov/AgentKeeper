$Env:u  = 'https://dev.azure.com/xkit/Todo/_apis'
$Env:uo = 'https://dev.azure.com/xkit/_apis'

#$Env:authFull = 'Basic '
$ErrorActionPreference = "Stop"

Write-Host 'Auth1'
Write-Host $Env:authFull

Write-Host 'Auth2'
Write-Host ${Env:authFull}
Write-Host (${Env:authFull}).Length

$authFull=${Env:authFull}
if ([string]::IsNullOrEmpty($authFull)) {
    $authFull=$args[0] + " " + $args[1]
    Write-Host 'Auth3'
    Write-Host $authFull
}

if ([string]::IsNullOrWhiteSpace($authFull)) {
    throw "No authorization"
}

$h = @{
    Authorization = $authFull;
    'Content-Type' = 'application/json';
    Accept = 'application/json';
}

# Pools
Write-Host 'Requesting Pools...'
$j = (iwr -UseBasicParsing -Headers $h -Uri "$Env:uo/distributedtask/pools?api-version=6.0").Content
try {
    $r = ConvertFrom-Json $j
} catch {
    $j
    throw
}
$poolDefault = $r.value | Where-Object name -eq 'Default'
$poolAp = $r.value | Where-Object name -eq 'Azure Pipelines'
#$poolAp

#$r.value[0]
#$r.value | FT -Property id,name,autoProvision,autoUpdate,autoSize,isHosted,poolType,size,isLegacy,options

# Self-hosted agents
Write-Host 'Requestung Default Agents...'
$r = ConvertFrom-Json (iwr -UseBasicParsing -Headers $h -Uri "$Env:uo/distributedtask/pools/$($poolDefault.id)/agents?api-version=6.0").Content
$r.value | FT -Property id,name,enabled
$agents = $r.value | where enabled -eq 'True'

# Microsoft-hosted agents
Write-Host 'Requestung Microsoft Agents...'
$r = ConvertFrom-Json (iwr -UseBasicParsing -Headers $h -Uri "$Env:uo/distributedtask/pools/$($poolAp.id)/agents?api-version=6.0").Content
#$r.value[0]
#$r.value | FT -Property id,name,version,osDescription
#$agents = $r.value

#$agents | FT
#$agents[0]

# Requesting queues
$r = ConvertFrom-Json (iwr -UseBasicParsing -Headers $h -Uri "$Env:u/distributedtask/queues?api-version=6.0-preview").Content
$queueAp = $r.value | where name -eq 'Azure Pipelines'

# Run BD51 for all agents
$jobs = New-Object Collections.Generic.List[PSObject];
foreach ($i in $agents)
{
    $i.name
    $body = "
    { 
        ""definition"": {
            ""id"": 65
        },
        demands: [
            ""Agent.Name -equals $($i.name)""
        ],
        parameters: ""{AgentName: \""$($i.name)\""}""
    }"

    $body = $body | ConvertFrom-Json | ConvertTo-Json

    Write-Host 'Requestung Job Enqueue...'
    $r = ConvertFrom-Json (iwr -UseBasicParsing -Method Post -Headers $h -Uri "$Env:u/build/builds?api-version=6.0" -Body $body).Content
    $jobs.Add($r);
}
<#
Write-Host 'Requestung Linux @Microsoft Job Enqueue...'
$body = "
{ 
    ""definition"": { ""id"": 51 },
    ""queue"": { ""id"": $($queueAp.id) },
    ""agentSpecification"": { ""identifier"": ""ubuntu-20.04"" }
}"
$body = $body | ConvertFrom-Json | ConvertTo-Json
$r = ConvertFrom-Json (iwr -UseBasicParsing -Method Post -Headers $h -Uri "$Env:u/build/builds?api-version=6.0" -Body $body).Content
$jobs.Add($r);

Write-Host 'Requestung Windows @Microsoft Job Enqueue...'
$body = "
{ 
    ""definition"": { ""id"": 51 },
    ""queue"": { ""id"": $($queueAp.id) },
    ""agentSpecification"": { ""identifier"": ""windows-2019"" }
}"
$body = $body | ConvertFrom-Json | ConvertTo-Json
$r = ConvertFrom-Json (iwr -UseBasicParsing -Method Post -Headers $h -Uri "$Env:u/build/builds?api-version=6.0" -Body $body).Content
$jobs.Add($r);
#>

Write-Host "This builds are queued:"
$jobs | FT -Property id,uri,status

while ($true) {
    $done = $true
    $updated = $false
    $success = $true
    for ($i=0; $i -lt $jobs.Count; $i++)
    {
        $job = $jobs[$i]
        $r = ConvertFrom-Json (iwr -UseBasicParsing -Headers $h -Uri "$Env:u/build/builds/$($job.id)?api-version=6.0").Content
        #$r.status
        if ($job.id -ne $r.id) {
            Write-Host "Something went wrong, response id not matches job id"
        }
        if ($job.status -ne $r.status) {
            $jobs[$i] = $r
            $updated = $true
        }
        if ($r.status -ne 'completed') {
            $done = $false
        }
        if ($r.result -ne 'succeeded') {
            $success = $false
        }
    }
    if ($updated) {
        $jobs | FT -Property buildNumber,status,result
    }
    if ($done) {
        if ($success -ne $true) {
            throw "One of agent failed"
        }
        break
    }
    Start-Sleep 5
}
