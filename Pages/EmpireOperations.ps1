New-UDPage -Name "Empire - Operations" -Icon empire -Content {
  

    $Session:CurrentlySelectedAgent = "NULL"
   
    $EmpireAgents = Get-BSEmpireAgentData
    $EmpireModules = Get-BSEmpireModuleData

    #### Loading Done
    
    ## If Only ONE Agent Availible Just Select the First Agent


    New-UDLayout -Columns 1 {
        New-UDHeading -Size 4 -Content {
            "Agent Selection"
        } 
    }
    
    New-UDElement -Id "CurrentAgentUDElement" -Tag "b" -Content  {"Currently Selected Agent: $Session:CurrentlySelectedAgent"}
 
    $FirstAgentName = ($EmpireAgents | Select-Object -First 1 -Property 'name').name
    
    
    New-UDInput -Title "Target Agent" -Id "AgentSelectionOperations" -SubmitText "Confirm" -Content {
        New-UDInputField -Type 'select' -Name 'EmpireAgentName' -Values $EmpireAgents.name -DefaultValue $FirstAgentName -Placeholder "Select an Agent"
        
        

    } -Endpoint{
        if($EmpireAgentName)
        {
            $Session:CurrentlySelectedAgent = $EmpireAgentName
        }
        
        Write-BSAuditLog -BSLogContent "Empire Operations: Selected Agent $EmpireAgentName"

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
        $EmpireModules  | ForEach-Object {

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
                            New-UDInputField -Type 'textbox' -Name 'Options'
                        } -Endpoint {
                        
                            ## GET EMPIRE CONFIGO
                            
                            $EmpireConfiguration = Get-BSEmpireConfigData
                            
                            $EmpireBox = $EmpireConfiguration.empire_host
                            $EmpirePort = $EmpireConfiguration.empire_port
                            $EmpireToken = $EmpireConfiguration.empire_token

                            $Text = 'Empire Operations: Executing Action: ' +  $ModuleName +' on: ' + $EmpireAgentName + " which lives on $EmpireBox"
                            New-UDInputAction -Toast $Text
                            Write-BSAuditLog -BSLogContent $Text
                         
                            $EmpireModuleExeuction =  Start-BSEmpireModuleOnAgent -EmpireBox $EmpireBox -EmpireToken $EmpireToken -EmpirePort $EmpirePort -AgentName $EmpireAgentName -ModuleName $ModuleName -Options $ModuleOptions
                            

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
