New-UDPage -Name "EmpireDownloads" -Icon download -Endpoint {
    
    $EmpireAgents = Get-BSEmpireAgentData
    $EmpireModules = Get-BSEmpireModuleData
    $EmpireConfiguration = Get-BSEmpireConfigData
                                
    $EmpireBox = $EmpireConfiguration.empire_host
    $EmpirePort = $EmpireConfiguration.empire_port
    $EmpireToken = $EmpireConfiguration.empire_token

    

    New-UDInput -Title "Retrieve Files" -Id "AgentResultsRetrieval" -Content {
        
        New-UDInputField -Type 'select' -Name 'EmpireAgentName' -Values $EmpireAgents.name -DefaultValue (($EmpireAgents | Select-Object -First 1).Name) -Placeholder "Select an Agent"
        New-UDInputField -Type 'textbox' -Name 'WindowsCredentialName' -DefaultValue 'empireserver' -Placeholder 'Name of Generic Windows Credential to Connect to Empire Server'

    } -Endpoint {
        param($EmpireAgentName, $WindowsCredentialName)
        
        $DownloadFolder = $Cache:BSDownloadsPath

        if($DownloadFolder -notlike '*\')
        {
            $DownloadFolder =  $DownloadFolder + '\'
        }

        New-UDInputAction -Toast "Getting Results for Agent: $EmpireAgentName"
        Write-BSAuditLog -BSLogContent "Empire Results: Getting Results for Agent: $EmpireAgentName"

        # EXECUTE DOWNLOAD LOGS FOR AGENT
        Write-BSAuditLog -BSLogContent "Empire Results: Attempting to Download Data from Agent: $EmpireAgentName to $DownloadFolder"
        $AgentLogDownloadStatus = Get-AgentDownloads -EmpireServer $Cache:EmpireServer -EmpireAgentName $EmpireAgentName -EmpireBox $EmpireBox -DownloadFolder $DownloadFolder -CredentialName $WindowsCredentialName
            
        Sync-UDElement -Id 'DownloadedFilesGrid' -Broadcast

        Write-BSAuditLog -BSLogContent "Empire Results: Retrieval Completed"
  
    }


    New-UDGrid -Title "Downloaded Files" -Id "DownloadedFilesGrid" -Headers @("Name", "CreationTime", "Agent", "Download") -Properties @("Name", "CreationTime", "Agent","Download") -Endpoint {
        Get-BSDownloads | ForEach-Object {
       
            [PSCustomObject]@{
                Name = $_.Name
                CreationTime = $_.CreationTime
                Agent = $_.Agent
                Download = New-UDButton -Text "Download" -OnClick (New-UDEndpoint -Endpoint{
                    
                    $FileName = $ArgumentList[0]
                    $AgentFolder = $ArgumentList[1]
                    $FullPath = $ArgumentList[2]

                    $FullPathWeb = $FullPath.Replace(($Cache:BlueStrikeDataFolder+'\'),"")
                    $FullPathWeb = $FullPathWeb.Replace('\',"/")
                    
                    $WebFileURL = 'http://localhost:'+ $Cache:BlueStrikePort + '/' + $FullPathWeb
                    #Invoke-WebRequest $WebFileURL
                    Invoke-UDRedirect -Url $WebFileURL -OpenInNewWindow
                    

                } -ArgumentList $_.Name, $_.Agent, $_.FullPath)
            } 
        } | Out-UDGridData
    }


    New-UDElement -Tag "ul" -Id "ExecutionResults2" -Content {
        
    }

    New-UDElement -Tag "ul" -Id "ButtonOpenLoot" -Content {
        
    }
    

    
}
