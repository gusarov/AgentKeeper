$Env:u  = 'https://dev.azure.com/xkit/DHost/_apis'
$Env:uo = 'https://dev.azure.com/xkit/_apis'
#$Env:authFull = 'Basic '

Write-Host 'Auth'
Write-Host $Env:authFull

$h = @{
    Authorization = $Env:authFull;
    'Content-Type' = 'application/json';
    Accept = 'application/json';
}

# Pools
$r = ConvertFrom-Json (iwr -Headers $h -Uri "$Env:uo/distributedtask/pools?api-version=6.0").Content
$poolDefault = $r.value | where name -eq 'Default'
$poolAp = $r.value | where name -eq 'Azure Pipelines'

# MyAgents
$r = ConvertFrom-Json (iwr -Headers $h -Uri "$Env:uo/distributedtask/pools/$($poolDefault.id)/agents?api-version=6.0").Content
$r.value | FT -Property id,name
$agents = $r.value

# Run BD56 for all agents
$jobs = New-Object Collections.Generic.List[PSObject];
foreach ($i in $agents)
{
    $i.name
    $body = "
    { 
        ""definition"": {
            ""id"": 56
        },
        demands: [
            ""Agent.Name -equals $($i.name)""
        ]
    }"

    $body = $body | ConvertFrom-Json | ConvertTo-Json

    $r = ConvertFrom-Json (iwr -Method Post -Headers $h -Uri "$Env:u/build/builds?api-version=6.0" -Body $body).Content
    $jobs.Add($r);
}

Write-Host "This builds are queued:"
$jobs | FT -Property id,uri,status

while ($true) {
    $done = $true
    $updated = $false
    $success = $true
    for ($i=0; $i -lt $jobs.Count; $i++)
    {
        $job = $jobs[$i]
        $r = ConvertFrom-Json (iwr -Headers $h -Uri "$Env:u/build/builds/$($job.id)?api-version=6.0").Content
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
        if ($r.result -ne 'success') {
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
    Start-Sleep 2
}
