$Data = @()
$ResourcesJsonFile = '.\scan.json'

if(Test-Path $ResourcesJsonFile)
{
    $ResourcesJsonContent = ConvertFrom-Json -InputObject (Get-Content $ResourcesJsonFile -raw)

    #### Data Stuff
    foreach($Resource in $ResourcesJsonContent)
    {
        $Data = $Data +[PSCustomObject]@{HostName=($Resource.Hostname);IPv4=($Resource.IPv4);Status=($Resource.Status);Computer=(New-UDLink -Text "RDP" -Url "remotedesktop://$Resource.IPv4");Note="";Last="99s"}
    }

}

return $Data