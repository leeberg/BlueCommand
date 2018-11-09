$Data = @()
$ResourcesJsonFile = '.\EmpireConfig.json'

if(Test-Path $ResourcesJsonFile)
{
    $ResourcesJsonContent = ConvertFrom-Json -InputObject (Get-Content $ResourcesJsonFile -raw)

    #### Data Stuff
    foreach($Resource in $ResourcesJsonContent)
    {
    

        $Data = $Data +[PSCustomObject]@{
            api_username=($Resource.api_username);
            install_path=($Resource.install_path);
            version=($Resource.version);
        }
    }

}

return $Data
