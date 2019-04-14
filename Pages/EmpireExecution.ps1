New-UDPage -Name "EmpireExecution" -Icon empire -Endpoint {
  

    $Session:CurrentlySelectedAgent = "NULL"  
    $Session:EmpireModules = Get-BSEmpireModuleData
    
    ## If Only ONE Agent Availible Just Select the First Agent
    $Session:EmpireAgents = Get-BSEmpireAgentData
    if($Session:EmpireAgents)
    {
        $Session:CurrentlySelectedAgent = ($Session:EmpireAgents | Select-Object -First 1).name
    }


    #### Module "Package" Selection Box - With Boxes!
    New-UDGrid -Title "Package Selection" -Headers @("Name", "Description", " ") -Properties @("Name", "Description", "Execute") -Endpoint {
        $Session:EmpireModules  | ForEach-Object {

        [PSCustomObject]@{
            Name = $_.Name
            Description = $_.Description
            Execute = New-UDButton -Text "Execute" -OnClick (New-UDEndpoint -Endpoint { 

                $EmpireAgentName = $ArgumentList[0]
                $ModuleName =  $ArgumentList[1]
                $ModuleDescription = $ArgumentList[2]
                $ModuleOptions = $ArgumentList[3]

                Write-BSAuditLog -BSLogContent "Empire Operations: Planning Execution for $ModuleName on Agent $EmpireAgentName"

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
                            New-UDInputField -Type 'select' -Name 'EmpireAgentName' -Values $Session:EmpireAgents.name -DefaultValue $Session:CurrentlySelectedAgent -Placeholder "Select an Agent"
                            New-UDInputField -Type 'textbox' -Name 'OptionsJSON' -DefaultValue $null
                            } -Endpoint {
                        
                            ## GET EMPIRE CONFIGO
                            
                            $EmpireConfiguration = Get-BSEmpireConfigData
                            
                            $EmpireBox = $EmpireConfiguration.empire_host
                            $EmpirePort = $EmpireConfiguration.empire_port
                            $EmpireToken = $EmpireConfiguration.empire_token

                            ## TODO OPtions Parsing?
                            If($OptionsJSON)
                            {
                                $ExecutuionLog = 'Empire Operations: Executing Action: ' +  $ModuleName +' on: ' + $EmpireAgentName + " which lives on $EmpireBox"
                                Write-BSAuditLog -BSLogContent $ExecutuionLog
                                $EmpireModuleExeuction = Start-BSEmpireModuleOnAgent -EmpireBox $EmpireBox -EmpireToken $EmpireToken -EmpirePort $EmpirePort -AgentName $EmpireAgentName -ModuleName $ModuleName
                            }
                            else 
                            {
                                $ExecutuionLog = 'Empire Operations: Executing Action: ' +  $ModuleName +' WITH OPTIONS: ' + $OptionsJSON + ' on: ' + $EmpireAgentName + " which lives on $EmpireBox"
                                Write-BSAuditLog -BSLogContent $ExecutuionLog
                                $EmpireModuleExeuction = Start-BSEmpireModuleOnAgent -EmpireBox $EmpireBox -EmpireToken $EmpireToken -EmpirePort $EmpirePort -AgentName $EmpireAgentName -ModuleName $ModuleName -Options $OptionsJSON
                            }
                                                                           
                            
                            Write-BSAuditLog -BSLogContent $EmpireModuleExeuction

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


}
