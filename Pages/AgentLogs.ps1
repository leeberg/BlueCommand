New-UDPage -Name "EmpireAgentLogs" -Icon file -Endpoint {
    
    $EmpireAgents = Get-BSEmpireAgentData
    $EmpireModules = Get-BSEmpireModuleData
    $EmpireConfiguration = Get-BSEmpireConfigData
                                
    $EmpireBox = $EmpireConfiguration.empire_host
    $EmpirePort = $EmpireConfiguration.empire_port
    $EmpireToken = $EmpireConfiguration.empire_token

    
    New-UDInput -Title "Retrieve Logs" -Id "AgentResultsRetrieval" -Content {
        
        New-UDInputField -Type 'select' -Name 'EmpireAgentName' -Values $EmpireAgents.name -DefaultValue (($EmpireAgents | Select-Object -First 1).Name) -Placeholder "Select an Agent"
        New-UDInputField -Type 'textbox' -Name 'WindowsCredentialName' -DefaultValue ($Cache:WindowsCredentialName) -Placeholder 'Name of Generic Windows Credential to Connect to Empire Server'

    } -Endpoint {
        param($EmpireAgentName, $WindowsCredentialName)
        
        $DownloadFolder = $Cache:BSDownloadsPath

        if($DownloadFolder -notlike '*\')
        {
            $DownloadFolder =  $DownloadFolder + '\'
        }

        $LocalAgentDownloadFolder = $DownloadFolder + $EmpireAgentName

        New-UDInputAction -Toast "Getting Results for Agent: $EmpireAgentName"
        Write-BSAuditLog -BSLogContent "Empire Results: Getting Results for Agent: $EmpireAgentName"

        # EXECUTE DOWNLOAD LOGS FOR AGENT
        Write-BSAuditLog -BSLogContent "Empire Results: Attempting to Download Data from Agent: $EmpireAgentName to $DownloadFolder"
        $AgentLogDownloadStatus = Get-AgentDownloads -EmpireServer $Cache:EmpireServer -EmpireAgentName $EmpireAgentName -EmpireBox $EmpireBox -DownloadFolder $DownloadFolder -CredentialName $WindowsCredentialName
        
        Write-BSAuditLog -BSLogContent "Empire Results: Attempting to Read Downloaded Data from Agent: $EmpireAgentName"
        $AgentLogDetails = Get-LocalAgentLogDetails -EmpireAgentName $EmpireAgentName -DownloadFolder $DownloadFolder
        


        Show-UDModal -Content {
            New-UDHeading -Size 4 -Text "Agent Results Download"
            New-UDHeading -Size 6 -Text "Agent: $EmpireAgentName Results downloaded to: $LocalAgentDownloadFolder"
            New-UDTable -Title "Agent Logs" -Headers @("TimeStamp", "Message")  -Endpoint {

                #TODO - THIS IS BUG! TABLE WORKS FINE
                    $AgentLogDetails | Out-UDTableData -Property @("TimeStamp","Message")
            }

        
        }



        Write-BSAuditLog -BSLogContent "Empire Results: Retrieval and Display Completed"
  
    }

    

    
}
