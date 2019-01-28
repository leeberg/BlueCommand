New-UDPage -Name "Empire - Operations" -Icon empire -Content {
  
    <#
     ## GET EMPIRE CONFIGO
     $ResourcesConfigJsonFile = '.\EmpireConfig.json'

     if(Test-Path $ResourcesConfigJsonFile)
     {
         $ResourcesEmpireConfig = ConvertFrom-Json -InputObject (Get-Content $ResourcesConfigJsonFile -raw)
         $EmpireBox = $ResourcesEmpireConfig.empire_host
         $EmpirePort = $ResourcesEmpireConfig.empire_port
         $EmpireToken = $ResourcesEmpireConfig.empire_token
     }
    
     New-UDGrid -Title "Empire Config" -Headers @("empire_host", "empire_port", "empire_token", "version", "api_username", "install_path") -Properties @("empire_host", "empire_port", "empire_token", "version", "api_username", "install_path") -AutoRefresh -Endpoint {
        $ResourcesEmpireConfig = ConvertFrom-Json -InputObject (Get-Content $ResourcesConfigJsonFile -raw)
        $ResourcesEmpireConfig | Out-UDGridData
    }

    #>
    ## GET AGENTS
    $ResourcesAgentsJsonFile = '.\EmpireAgents.json'
    #$CurrentlySelectedAgent = "NULL"
    $Session:CurrentlySelectedAgent = "NULL"

    if(Test-Path $ResourcesAgentsJsonFile)
    {
        $ResourcesAgentJsonContent = ConvertFrom-Json -InputObject (Get-Content $ResourcesAgentsJsonFile -raw)
    }

    ## GET LISTS OF MODULES
    $ResourcesModulesJsonFile = '.\EmpireModules.json'

    if(Test-Path $ResourcesModulesJsonFile)
    {
        $ResourcesModuleJsonContent = ConvertFrom-Json -InputObject (Get-Content $ResourcesModulesJsonFile -raw)
    }
   


    #### Loading Done
    
    ## If Only ONE Agent Availible Just Select the First Agent


    New-UDLayout -Columns 1 {
        New-UDHeading -Size 4 -Content {
            "Agent Selection"
        } 
    }
    
    New-UDElement -Id "CurrentAgentUDElement" -Tag "b" -Content  {"Currently Selected Agent: $Session:CurrentlySelectedAgent"}
 
    $FirstAgentName = ($ResourcesAgentJsonContent | Select-Object -First 1 -Property 'name').name
    
    New-UDInput -Title "Target Agent" -Id "AgentSelectionOperations" -SubmitText "Confirm" -Content {
        New-UDInputField -Type 'select' -Name 'EmpireAgentName' -Values $ResourcesAgentJsonContent.name -DefaultValue $FirstAgentName -Placeholder "Select an Agent"
    
    } -Endpoint{
        if($EmpireAgentName)
        {
            $Session:CurrentlySelectedAgent = $EmpireAgentName
        }
      
        Clear-UDElement -Id "CurrentAgentUDElement"
        Add-UDElement -ParentId "CurrentAgentUDElement" -Content {
                New-UDElement -Tag "b" -Content  {"Currently Selected Agent: $Session:CurrentlySelectedAgent"}
        }
        
    }


    New-UDLayout -Columns 1 {
        New-UDHeading -Size 4 -Content {
            "Package Selection"
        } 
    }

    #### Module "Package" Selection Box - With Boxes!
    New-UDGrid -Title "Package Selection" -Headers @("Name", "Description", " ") -Properties @("Name", "Description", "Execute") -AutoRefresh -Endpoint {
        $JsonModuleData = .\ReadEmpireModules.ps1 
        $JsonModuleData | ForEach-Object {

        [PSCustomObject]@{
            Name = $_.Name
            Description = $_.Description
            Execute = New-UDButton -Text "Execute" -OnClick (New-UDEndpoint -Endpoint { 

                $EmpireAgentName = $ArgumentList[0]
                $ModuleName =  $ArgumentList[1]
                $ModuleDescription = $ArgumentList[2]
                $ModuleOptions = $ArgumentList[3]

                if ($EmpireAgentName -ne $null)
                {

                    Show-UDModal -Content {
                        New-UDTable -Title "Strike Package Details" -Headers @("Name", "Description", "Agent") -Endpoint {
                            @{
                                'Name' = $ModuleName
                                'Description' = $ModuleDescription
                                'Agent' = $EmpireAgentName
                            } | Out-UDTableData -Property @("Name", "Description", "Agent", "Options")
                            
                        }

                        New-UDTable -Title "Module Options" -Headers @("Option Name", "Definition") -Endpoint {
                            $ModuleOptions | Out-UDTableData -Property @("Name", "Definition")
                        }

                        New-UDInput -Title "Execute Strike Package" -Id "AgentModuleOperations" -SubmitText "Execute" -Content {
                        
                        } -Endpoint {
                        
                            ## GET EMPIRE CONFIGO
                            $ResourcesConfigJsonFile = '.\EmpireConfig.json'
                
                            if(Test-Path $ResourcesConfigJsonFile)
                            {
                                $ResourcesEmpireConfig = ConvertFrom-Json -InputObject (Get-Content $ResourcesConfigJsonFile -raw)
                                $EmpireBox = $ResourcesEmpireConfig.empire_host
                                $EmpirePort = $ResourcesEmpireConfig.empire_port
                                $EmpireToken = $ResourcesEmpireConfig.empire_token
                            }
                
                
                            $Text = 'Executing Action: ' +  $ModuleName +' on: ' + $EmpireAgentName + " which lives on $EmpireBox"
                            
                            $EmpireModuleExeuction = .\Tools\Empire\ExecuteModuleOnAgent.ps1 -EmpireBox $EmpireBox -EmpireToken $EmpireToken -EmpirePort $EmpirePort -AgentName $EmpireAgentName -ModuleName $ModuleName
                            New-UDInputAction -Toast $EmpireModuleExeuction

                            Clear-UDElement -Id "StrikePackageExecution"
                            Add-UDElement -ParentId "StrikePackageExecution" -Content {
                                    New-UDHtml -Markup '<b>STRIKE STATUS: <font size="3" color="red">EXECUTED</font></b>'
                            }


                        }


                        New-UDElement -Id "StrikePackageExecution" -Tag "b" -Content  {"STRIKE STATUS: DEPLOYMENT READY"}
    
                        
                    } 

                }
                else{
                    
                    Show-UDModal -Content {
                        New-UDHeading -Size 4 -Text "Invalid Selection!"
                        New-UDHeading -Size 6 -Text "You must Select a VALID Agent First!"
                    }
                }

            } -ArgumentList $Session:CurrentlySelectedAgent, $_.Name, $_.Description, $_.Options)
       }

        } | Out-UDGridData
        

    }      

  
           
    <#
    New-UDInput -Title "Execute Module" -Id "AgentModuleOperations" -Content {
        New-UDInputField -Type 'select' -Name 'EmpireAgentName' -Values $ResourcesAgentJsonContent.name
        New-UDInputField -Type 'select' -Name 'ModuleName' -Values $ResourcesModuleJsonContent.name
        New-UDInputField -Type 'textbox' -Name 'ModuleOptions'
    } -Endpoint {
        param($EmpireAgentName, $ModuleName, $ModuleOptions)


        ## GET EMPIRE CONFIGO
        $ResourcesConfigJsonFile = '.\EmpireConfig.json'

        if(Test-Path $ResourcesConfigJsonFile)
        {
            $ResourcesEmpireConfig = ConvertFrom-Json -InputObject (Get-Content $ResourcesConfigJsonFile -raw)
            $EmpireBox = $ResourcesEmpireConfig.empire_host
            $EmpirePort = $ResourcesEmpireConfig.empire_port
            $EmpireToken = $ResourcesEmpireConfig.empire_token
        }


        $Text = 'Executing Action: ' +  $ModuleName +' on: ' +$EmpireAgentName + " which lives on $EmpireBox"
        
        $EmpireModuleExeuction = .\Tools\Empire\ExecuteModuleOnAgent.ps1 -EmpireBox $EmpireBox -EmpireToken $EmpireToken -EmpirePort $EmpirePort -AgentName $EmpireAgentName -ModuleName $ModuleName
        New-UDInputAction -Toast $EmpireModuleExeuction

    }
    #> 
    
   


}
