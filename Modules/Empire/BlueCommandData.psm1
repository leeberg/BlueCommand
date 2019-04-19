#### All functions need to have proper function params, synopsis, help, etc....
#### Also where my psd1 file at

Function Get-BSJSONObject 
{
Param(
    [Parameter(Mandatory=$true)] $BSFile
)

    if(Test-Path($BSFile))
    {
        $FileContents = Get-Childitem -file $BSFile  
        $Length = $FileContents.Length

        iF($Length -ne 0)
        {
            $JsonObject = ConvertFrom-Json -InputObject (Get-Content $BSFile -raw)
            return $JsonObject
        }
        else 
        {
            # Empty File
            return $null
        }

        
    }
    else 
    {
        # Does not Exist
        return $null
    }
}

Function Get-BSEmpireAgentData()
{

    $Data = @()
    $ResourcesJsonContent = Get-BSJSONObject -BSFile $Cache:EmpireAgentFilePath

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
    
    return $Data
}



Function Get-BSEmpireConfigData()
{

    $Data = @()
    $ResourcesJsonContent = Get-BSJSONObject -BSFile $Cache:EmpireConfigFilePath

    #### Data Stuff
    foreach($Resource in $ResourcesJsonContent)
    {
        $Data = $Data +[PSCustomObject]@{
            empire_host=($Resource.empire_host);
            empire_port=($Resource.empire_port);
            empire_token=($Resource.empire_token);
            api_username=($Resource.api_username);
            install_path=($Resource.install_path);
            version=($Resource.version);
            sync_time=($Resource.sync_time)
        }
    }

    return $Data


}


Function Get-BSEmpireModuleData()
{
    
    $Data = @()
    $Options = @()
    $FirstPartOfDefinition = '^.*=@{Description='
    $SecondPartOfDefinition = ';.*;.*Value=.*}'

    $ResourcesJsonContent = Get-BSJSONObject -BSFile $Cache:EmpireModuleFilePath

    #### Data Stuff
    foreach($Module in $ResourcesJsonContent)
    {

        #Propertize the Module Objects
        $ModuleOptionsObject = @()
        $ModuleOptions = $Module.options 
        
        $ModuleOptionsNotes = $ModuleOptions | Get-Member -MemberType NoteProperty
        ForEach($Note in $ModuleOptionsNotes)
        {

            $OptionDefinitionFormatted = $Note.Definition
            $OptionDefinitionFormatted = $OptionDefinitionFormatted -replace $FirstPartOfDefinition," "
            $OptionDefinitionFormatted = $OptionDefinitionFormatted -replace $SecondPartOfDefinition,""

            $ModuleOptionsObject = $ModuleOptionsObject +[PSCustomObject]@{
                Name=($Note.Name);
                Definition=($OptionDefinitionFormatted);
            }
        }


        $Data = $Data +[PSCustomObject]@{
            Name=($Module.name);
            Author=($Module.Author);
            Description=($Module.Description);
            Language=($Module.Language);
            NeedsAdmin=($Module.NeedsAdmin);
            OpsecSafe=($Module.OpsecSafe);
            Options=($ModuleOptionsObject);
        }
    }



    return $Data


}

Function Get-BSDownloadsCount
{   
    $Count = 0
    $BSDownloadsPath = $Cache:BSDownloadsPath
    $AgentFiles = ($BSDownloadsPath + '\') | Get-ChildItem -Recurse | where {! $_.PSIsContainer }
    $Count = $AgentFiles.Count

    return $Count
}


Function Get-BSDownloads
{   
    param(
        $AgentName = $null
    )

    $BSDownloadsPath = $Cache:BSDownloadsPath

    $DownloadedFiles = @()

    if($AgentName -ne $null)
    {
        $AgentFolderName = $Folder.Name
        $AgentFolderPath = $BSDownloadsPath + '\'+ $AgentName
        $AgentFiles = ($AgentFolderPath + '\') | Get-ChildItem -Recurse | where { ! $_.PSIsContainer }
        ForEach($File in $AgentFiles)
        {
            $FullPath = $File.FullName
            $ParentDirectory = $AgentFolderName
            $Directory = $File.Directory.FullName
            $DownloadedFiles += $File | Select-Object -Property  Name, FullName, CreationTime, @{Name="Agent"; Expression = {$ParentDirectory}}, @{Name="Directory"; Expression = {$Directory}}, @{Name="FullPath"; Expression = {$FullPath}}
        }
        
    }
    else 
    {
        $AgentFolders = ($Cache:BSDownloadsPath + '\') | Get-ChildItem | ?{ $_.PSIsContainer }

        Foreach($Folder in $AgentFolders)
        {
            $AgentFolderName = $Folder.Name
            $AgentFolderPath = $Folder.FullName
            $AgentFiles = ($AgentFolderPath + '\') | Get-ChildItem -Recurse | where { ! $_.PSIsContainer }
            ForEach($File in $AgentFiles)
            {
                $FullPath = $File.FullName
                $ParentDirectory = $AgentFolderName
                $Directory = $File.Directory.FullName
                $DownloadedFiles += $File | Select-Object -Property  Name, FullName, CreationTime, @{Name="Agent"; Expression = {$ParentDirectory}},@{Name="Directory"; Expression = {$Directory}}, @{Name="FullPath"; Expression = {$FullPath}}
            }
        }
    }

    return ($DownloadedFiles)

}



Function Get-BSNetworkScanData()
{

    $Data = @()
    $ResourcesJsonContent = Get-BSJSONObject -BSFile $Cache:NetworkScanFilePath
        
    #### Data Stuff
    foreach($Resource in $ResourcesJsonContent)
    {
        $Data = $Data +[PSCustomObject]@{
            HostName=($Resource.Hostname);
            IPv4=($Resource.IPv4);
            Status=($Resource.Status);
            Computer=(New-UDLink -Text "RDP" -Url "remotedesktop://$Resource.IPv4");
            Note="";
            LastScan=($Resource.ScanTime.DateTime);
            isEmpire=($Resource.EmpireServer);
        }
    }
       
    return $Data

}



Function Clear-BSJON
{
Param(
    [Parameter(Mandatory=$true)] $BSFile
)
    if(Test-Path($BSFile))
    {
         # Clear Existings
        Clear-Content $BSFile -Force
    }
    else 
    {
        # Does not Exist
    }
}


Function Write-BSJSON
{
Param (
    [Parameter(Mandatory=$true)] $BSFile = '',
    [Parameter(Mandatory=$true)] $BSObjectData
)

$BSObjectData | ConvertTo-Json | Out-File $BSFile -Append


}


Function Write-BSObjectToJSON
{
Param (
    [Parameter(Mandatory=$true)] $BSFile = '',
    [Parameter(Mandatory=$true)] $BSObjectData
)

$BSObjectData | ConvertTo-Json | Out-File $BSFile -Append


}




Function Write-BSEmpireAgentData
{
Param (
    [Parameter(Mandatory=$true)] $BSObjectData
)

    Clear-BSJON -BSFile $Cache:EmpireAgentFilePath
    Write-BSJSON -BSFile $Cache:EmpireAgentFilePath -BSObjectData $BSObjectData

}


Function Write-BSEmpireConfigData
{
Param (
    [Parameter(Mandatory=$true)] $BSObjectData
    )
    Clear-BSJON -BSFile $Cache:EmpireConfigFilePath
    Write-BSJSON -BSFile $Cache:EmpireConfigFilePath -BSObjectData $BSObjectData


}

Function Write-BSEmpireModuleData
{
Param (
    [Parameter(Mandatory=$true)] $BSObjectData
)
    Clear-BSJON -BSFile $Cache:EmpireModuleFilePath
    Write-BSJSON -BSFile $Cache:EmpireModuleFilePath -BSObjectData $BSObjectData
    

}



Function Write-BSNetworkScanData
{
Param (
    [Parameter(Mandatory=$true)] $BSObjectData
)
    Clear-BSJON -BSFile $Cache:NetworkScanFilePath
    Write-BSJSON -BSFile $Cache:NetworkScanFilePath -BSObjectData $BSObjectData
    
}

Function Write-BSAuditLog
{
Param (
    [Parameter(Mandatory=$true)] $BSLogContent
)
    $BSLogContentFormatted = ($(Get-Date -Format 'yyyy-MM-dd hh:mm:ss') + ' : ' + $BSLogContent)
    $BSLogContentFormatted | Out-File $Cache:BSLogFilePath -Append
}