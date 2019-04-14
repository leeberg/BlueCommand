New-UDPage -Name "EmpireResults" -Icon empire -Endpoint {
    
    $EmpireAgents = Get-BSEmpireAgentData
    $EmpireModules = Get-BSEmpireModuleData
    $EmpireConfiguration = Get-BSEmpireConfigData
                                
    $EmpireBox = $EmpireConfiguration.empire_host
    $EmpirePort = $EmpireConfiguration.empire_port
    $EmpireToken = $EmpireConfiguration.empire_token


    New-UDInput -Title "Retrieve Results" -Id "AgentResultsRetrieval" -Content {
        
        New-UDInputField -Type 'select' -Name 'EmpireAgentName' -Values $EmpireAgents.name -DefaultValue "Null" -Placeholder "Select an Agent"
        New-UDInputField -Type 'textbox' -Name 'DownloadFolder' -DefaultValue "C:\Downloads" -Placeholder "Set Agent Download Location"
        New-UDInputField -Type 'textbox' -Name 'WindowsCredentialName' -DefaultValue 'empireserver' -Placeholder 'Name of Generic Windows Credential to Connect to Empire Server'

    } -Endpoint {
        param($EmpireAgentName, $DownloadFolder)
        
      

        if($DownloadFolder -notlike '*\')
        {
            $DownloadFolder =  $DownloadFolder + '\'
        }

        New-UDInputAction -Toast "Getting Results for Agent: $EmpireAgentName"
        Write-BSAuditLog -BSLogContent "Empire Results: Getting Results for Agent: $EmpireAgentName"

        # EXECUTE DOWNLOAD LOGS FOR AGENT
        Write-BSAuditLog -BSLogContent "Empire Results: Attempting to Download Data from Agent: $EmpireAgentName to $DownloadFolder"
        $AgentLogDownloadStatus = Get-AgentDownloads -EmpireAgentName $EmpireAgentName -EmpireBox $EmpireBox -DownloadFolder $DownloadFolder -CredentialName $WindowsCredentialName
        

        # READ DOWNLOADED LOGS FOR AGENT
        Write-BSAuditLog -BSLogContent "Empire Results: Attempting to Read Downloaded Data from Agent: $EmpireAgentName"
        $JsonAgentLogDetails = Get-LocalAgentLogDetails -EmpireAgentName $EmpireAgentName -DownloadFolder $DownloadFolder
        

        $LocalAgentDownloadFolder = $DownloadFolder + $EmpireAgentName


    
        Add-UDElement -ParentId "ExecutionResults2" -Content {
            New-UDElement -Tag "li" -Content  {New-UDPreloader}
        }            

        
        Clear-UDElement -Id "ExecutionResults2"
        Clear-UDElement -Id "ButtonOpenLoot"
        

        ### ADD RESULTS
        ForEach($result in $JsonAgentLogDetails)
        {
           
            Add-UDElement -ParentId "ExecutionResults2" -Content {
             #   New-UDElement -Tag "li" -Content  {$result.TimeStamp + $result.Message}
            }

        }

        
        
        Show-UDModal -Content {
            New-UDHeading -Size 4 -Text "Agent Results Download"
            New-UDHeading -Size 6 -Text "Agent: $EmpireAgentName Results downloaded to: $LocalAgentDownloadFolder"
            #New-UDHtml -Markup ('<b>Agent: '+$EmpireAgentName+'Results</b> downloaded to: '+ $LocalAgentDownloadFolder)
            New-UDTable -Title "Agent Results" -Headers @("TimeStamp", "Message") -Style striped -Endpoint {
                $JsonAgentLogDetails | Out-UDTableData -Property @("TimeStamp", "Message")
                
            }
        }

        ## ADD BUTTON
        Add-UDElement -ParentId "ButtonOpenLoot" -Content {
               
            # New-UDHtml -Markup ('<a href="file://'+$LocalAgentDownloadFolder+'" id="btnGetLoot" class="btn">Open Loot</a>')

        }

        Write-BSAuditLog -BSLogContent "Empire Results: Retrieval and Display Completed"
  
    }

    New-UDElement -Tag "ul" -Id "ExecutionResults2" -Content {
        
    }

    New-UDElement -Tag "ul" -Id "ButtonOpenLoot" -Content {
        
    }
    

    
}
