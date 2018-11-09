$Data = @()
$ResourcesJsonFile = '.\EmpireAgents.json'

if(Test-Path $ResourcesJsonFile)
{
    $ResourcesJsonContent = ConvertFrom-Json -InputObject (Get-Content $ResourcesJsonFile -raw)

    #### Data Stuff
    foreach($Resource in $ResourcesJsonContent)
    {
    

        $Data = $Data +[PSCustomObject]@{
            id=($Resource.id);
            name=($Resource.name);
            checkin_time=($Resource.checkin_time);
            external_ip=($Resource.external_ip);
            hostname=($Resource.hostname);
            internal_ip=($Resource.internal_ip);
            langauge=($Resource.langauge);
            langauge_version=($Resource.langauge_version);
            lastseen_time=($Resource.lastseen_time);
            listener=($Resource.listener);
            os_details=($Resource.os_details);
            username=($Resource.username);
        }
    }

}

return $Data