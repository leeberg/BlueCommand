$Data = @()
$ResourcesJsonFile = '.\EmpireModules.json'

if(Test-Path $ResourcesJsonFile)
{
    $ResourcesJsonContent = ConvertFrom-Json -InputObject (Get-Content $ResourcesJsonFile -raw)

    #### Data Stuff
    foreach($Resource in $ResourcesJsonContent)
    {
        $Data = $Data +[PSCustomObject]@{
            Name=($Resource.name);
            Author=($Resource.Author);
            Description=($Resource.Description);
            Language=($Resource.Language);
            NeedsAdmin=($Resource.NeedsAdmin);
            OpsecSafe=($Resource.OpsecSafe);
            options=($Resource.options);
        }
    }

}

return $Data