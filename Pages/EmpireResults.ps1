New-UDPage -Name "Empire - Results" -Icon empire -Content {
        
    New-UDLayout -Columns 1 {
        New-UDHeading -Size 4 -Content {
            New-UDIcon -Icon money
            "    EMPIRE Agent Results"
        } 
       New-UDHeading -Text "Choose Agent and Download Location" -Size 6
       # New-UDHeading -Text "First we Will SElect an Agent" -Size 6 
       # New-UDHeading -Text "Second we will download with POSH-SSH" -Size 6 
       # New-UDHeading -Text "Finally we will dump and parse the log" -Size 6 
    }
    
    
    ## GET AGENTS
    $ResourcesAgentsJsonFile = '.\EmpireAgents.json'

    if(Test-Path $ResourcesAgentsJsonFile)
    {
        $ResourcesAgentJsonContent = ConvertFrom-Json -InputObject (Get-Content $ResourcesAgentsJsonFile -raw)
    }

    New-UDInput -Title "Retrieve Results" -Id "AgentResultsRetrieval" -Content {
        New-UDInputField -Type 'select' -Name 'EmpireAgentName' -Values $ResourcesAgentJsonContent.name -DefaultValue "Null" -Placeholder "Select an Agent"
        New-UDInputField -Type 'textbox' -Name 'DownloadFolder' -DefaultValue "C:\Downloads" -Placeholder "Set Agent Download Location"

    } -Endpoint {
        param($EmpireAgentName, $DownloadFolder)
        
      

        if($DownloadFolder -notlike '*\')
        {
            $DownloadFolder =  $DownloadFolder + '\'
        }

        ## GET EMPIRE CONFIGO
        $ResourcesConfigJsonFile = '.\EmpireConfig.json'

        if(Test-Path $ResourcesConfigJsonFile)
        {
            $ResourcesEmpireConfig = ConvertFrom-Json -InputObject (Get-Content $ResourcesConfigJsonFile -raw)
            $EmpireBox = $ResourcesEmpireConfig.empire_host
            $EmpirePort = $ResourcesEmpireConfig.empire_port
            $EmpireToken = $ResourcesEmpireConfig.empire_token
        }

        New-UDInputAction -Toast "Getting Results for Agent: $EmpireAgentName"

        # EXECUTE DOWNLOAD LOGS FOR AGENT
        $AgentLogDownloadStatus = .\Tools\Empire\Get-AgentDownloads.ps1 -EmpireAgentName $EmpireAgentName -EmpireBox $EmpireBox -DownloadFolder $DownloadFolder
        

        # READ DOWNLOADED LOGS FOR AGENT
        $JsonAgentLogDetails = .\Tools\Empire\Get-LocalAgentLogDetails.ps1 -EmpireAgentName $EmpireAgentName -DownloadFolder $DownloadFolder
        

        $LocalAgentDownloadFolder = $DownloadFolder + $EmpireAgentName


    
        Add-UDElement -ParentId "ExecutionResults2" -Content {
            New-UDElement -Tag "li" -Content  {New-UDPreloader}
        }            

        #$EmpireResults = .\Tools\Empire\GetEmpireAgentResults.ps1 -EmpireBox $EmpireBox -EmpireToken $EmpireToken -EmpirePort $EmpirePort -AgentName $EmpireAgentName
        
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
  
    }

    New-UDElement -Tag "ul" -Id "ExecutionResults2" -Content {
        
    }

    New-UDElement -Tag "ul" -Id "ButtonOpenLoot" -Content {
        
    }
    

    
}
