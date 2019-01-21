function New-UDPreloader {
    [CmdletBinding(DefaultParameterSetName = "indeterminate")]
    param(
        [Parameter(ParameterSetName = "determinate")]
        [ValidateRange(0, 100)]
        $PercentComplete
        )
    
    New-UDElement -Tag "div" -Attributes @{
        className = "progress"
    } -Content {
        $Attributes = @{
            className = $PSCmdlet.ParameterSetName
        }

        if ($PSCmdlet.ParameterSetName -eq "determinate") {
            $Attributes["style"] = @{
                width = "$($PercentComplete)%"
            }
        }

        New-UDElement -Tag "div" -Attributes $Attributes
    }
}


function Start-BSDash {

    #### SETUP STUFF
    param($Port = 10000) 

    

    $HomeUDPage = New-UDPage -Name "Home" -Icon home -Content {
            
        New-UDRow -Columns {            
            New-UDColumn -Size 2 {         
                New-UDCard -Id 'crd_home1' -Title ""  -Content{
                    New-UDButton -Id "BTN_GotoEmpireOperations" -Icon bomb -Text "Execute Strike" -OnClick {                                 
                        $ButtonVar = Invoke-UDRedirect -Url  "/Empire---Operations" 
                    }
                }
            }
            New-UDColumn -Size 2 {         
                New-UDCard -Id 'crd_home1' -Title "" -Content{
                    New-UDButton -Id "BTN_GotoEmpireResults" -Icon money -Text "Empire Results" -OnClick {                                 
                        $ButtonVar = Invoke-UDRedirect -Url  "/Empire---Results" 
                    }         
                }
            }   
            New-UDColumn -Size 2 {         
                New-UDCard -Id 'crd_home1' -Title "" -Content{
                    New-UDButton -Id "BTN_GotoEmpireConfiguration" -Icon empire -Text "Empire Configuration" -OnClick {                                     
                        $ButtonVar = Invoke-UDRedirect -Url  "/Empire---Configuration" 
                    }
                }
            }   
            New-UDColumn -Size 2 {         
                New-UDCard -Id 'crd_home1' -Title "" -Content{
                    New-UDButton -Id "BTN_GotoEmpireConfiguration" -Icon empire -Text "Empire Config" -OnClick {                                     
                        $ButtonVar = Invoke-UDRedirect -Url  "/Empire---Configuration" 
                    }
                }     
            }  
            New-UDColumn -Size 2 {         
                New-UDCard -Id 'crd_home1' -Title "" -Content{
                    New-UDButton -Id "BTN_GotoEmpireConfiguration" -Icon empire -Text "Empire Config" -OnClick {                                     
                        $ButtonVar = Invoke-UDRedirect -Url  "/Empire---Configuration" 
                    }
                }     
            }
            New-UDColumn -Size 2 {         
                New-UDCard -Id 'crd_home1' -Title "" -Content{
                    New-UDButton -Id "BTN_GotoEmpireConfiguration" -Icon empire -Text "Empire Config" -OnClick {                                     
                        $ButtonVar = Invoke-UDRedirect -Url  "/Empire---Configuration" 
                    }
                }     
            }   


            
           
            
        }
        
        
        
            New-UDGrid -Title "Known Resources" -Headers @("HostName", "IPv4", "Status","Computer","Note","Last") -Properties @("HostName", "IPv4", "Status","Computer","Note","Last") -Endpoint {
                $JsonData = .\ReadResourceJson.ps1 
                $JsonData | Out-UDGridData
            }

            New-UDGrid -Title "Empire Agents" -Headers @("id", "name", "checkin_time","external_ip","hostname","internal_ip","langauge", "langauge_version", "lastseen_time","listener","os_details","username") -Properties @("id", "name", "checkin_time","external_ip","hostname","internal_ip","langauge", "langauge_version", "lastseen_time","listener","os_details","username") -AutoRefresh -Endpoint {
                $JsonData = .\ReadEmpireAgents.ps1 
                $JsonData | Out-UDGridData
            }  
        
                
            
        
    }

            
    # Port Scanner Page
    $Global:NetworkDiscoveryUDPage = New-UDPage -Name "Network - Discovery" -Icon search -Content {
        
            New-UDInput -Title "Discover Network Resources IPv4 Network Scan" -Id "DiscoveryInput" -Content {
                New-UDInputField -Type 'textarea' -Name 'StartAddress' -Placeholder 'Start IPv4 Address' -DefaultValue '192.168.200.1'
                New-UDInputField -Type 'textarea' -Name 'EndAddress' -Placeholder 'End IPv4 Address' -DefaultValue '192.168.200.255'
            
            } -Endpoint{
                param($StartAddress, $EndAddress)
                
                if (($StartAddress -ne '') -and ($EndAddress -ne ''))
                {
                    # Do a IPV4 Scan
                    $NetworkScanResults = .\Tools\NetworkScan\IPv4NetworkScan.ps1 -StartIPv4Address $StartAddress -EndIPv4Address $EndAddress

                    # Output a new Grid based on that info
                    New-UDInputAction -Content @(
                    
                        New-UDGrid -Title "Network Disovery Results" -Headers @("IPv4", "Status", "Hostname") -Properties @("IPv4", "Status", "Hostname") -Endpoint {
                            $NetworkScanResults | Select-Object -Property Hostname,@{Name="IPv4"; Expression = {$_.IPv4Address.IPAddressToString}},Status | Out-UDGridData
                        }
                
                    )

                    # Save to JSON File

                    if(Test-Path '.\scan.json')
                    {
                        # Clear Existings
                        Clear-Content '.\scan.json'
                    }
                    
                    $NetworkScanResults | Select-Object -Property Hostname,@{Name="IPv4"; Expression = {$_.IPv4Address.IPAddressToString}},Status | ConvertTo-Json >> '.\scan.json'

                }
                else {
                    New-UDInputAction -Toast "Fill all required fields!"
                }

            }
    }


    # Operations Page
    $Global:NetworkOperationsUDPage = New-UDPage -Name "Network - Operations" -Icon fighter_jet -RefreshInterval 5 -Content {
        
            $ResourcesJsonFile = '.\scan.json'

            if(Test-Path $ResourcesJsonFile)
            {
                $ResourcesJsonContent = ConvertFrom-Json -InputObject (Get-Content $ResourcesJsonFile -raw)
            }
            
            New-UDInput -Title "Operations" -Id "HackForm" -Content {
                New-UDInputField -Type 'select' -Name 'Computer' -Values $ResourcesJsonContent.Hostname
                New-UDInputField -Type 'select' -Name 'Operation' -Values @("Ping", "Nuke", "RDP", "SSH", "NMAP") -DefaultValue "Ping"
                New-UDInputField -Type 'textarea' -Name 'AdditionalNotes' -Placeholder 'Additional Notes'
            } -Endpoint {
                param($Computer, $Operation, $AdditionalNotes)
                $MessageTimestamp = Get-Date
                

                IF($Operation -eq 'Ping')
                {
                    $Pingas = Test-Connection -ComputerName $Computer
                    
                    New-UDInputAction -Content @(
                                        
                        New-UDGrid -Title "Ping Result(s)"  -Headers @("Source", "IPV4Address","IPV6Address","Time(ms)") -Properties @("Source", "IPV4Address","IPV6Address","Time(ms)") -Endpoint {
                            $Pingas | Select-Object -Property @{Name="Source"; Expression = {$_.PSComputerName}},@{Name="IPV4Address"; Expression = {$_.IPv4Address.IPAddressToString}},@{Name="IPV6Address"; Expression = {$_.IPv6Address.IPAddressToString}}, @{Name="Time(ms)"; Expression = {$_.ResponseTime}} | Out-UDGridData
                        }

                    )
                }
                else {
                    New-UDInputAction -Toast "Operation $Operation is not implemented!"    
                }

            }
    }
        


    # Configuration Page
    $Global:EmpireConfigurationUDPage = New-UDPage -Name "Empire - Configuration" -Icon empire -Content {

            $ResourcesJsonFile = '.\scan.json'

            if(Test-Path $ResourcesJsonFile)
            {
                $ResourcesJsonContent = ConvertFrom-Json -InputObject (Get-Content $ResourcesJsonFile -raw)
            }


            New-UDInput -Title "Empire Configuration" -Id "EmpireConfiguration" -Content {
                New-UDInputField -Type 'select' -Name 'EmpireComputer' -Values $ResourcesJsonContent.Hostname
                New-UDInputField -Type 'textarea' -Name 'EmpirePort' -DefaultValue '1337'
                New-UDInputField -Type 'textarea' -Name 'EmpireToken' -DefaultValue '6jq0or8kcawfi4vjyktehwuqugv7uhxes04mrqkq'
            } -Endpoint {
                param($EmpireComputer, $EmpirePort, $EmpireToken)
                New-UDInputAction -Toast "Retrieving Empire Configurations!"
                
                if(Test-Path '.\EmpireConfig.json')
                {
                    # Clear Existings
                    Clear-Content '.\EmpireConfig.json'
                }

                $EmpireConfiguration = .\Tools\Empire\GetEmpireStatus.ps1 -EmpireBox $EmpireComputer -EmpireToken $EmpireToken -EmpirePort $EmpirePort
                $EmpireConfiguration | ConvertTo-Json >> '.\EmpireConfig.json'
                
                #AGENTS
                if(Test-Path '.\EmpireAgents.json')
                {
                    # Clear Existings
                    Clear-Content '.\EmpireAgents.json'
                }

                $EmpireAgents = .\Tools\Empire\GetEmpireAgents.ps1 -EmpireBox $EmpireComputer -EmpireToken $EmpireToken -EmpirePort $EmpirePort
                $EmpireAgents | ConvertTo-Json >> '.\EmpireAgents.json'

                #MODULES
                if(Test-Path '.\EmpireModules.json')
                {
                    # Clear Existings
                    Clear-Content '.\EmpireModules.json'
                }

                $EmpireAgents = .\Tools\Empire\GetEmpireModules.ps1 -EmpireBox $EmpireComputer -EmpireToken $EmpireToken -EmpirePort $EmpirePort
                $EmpireAgents | ConvertTo-Json >> '.\EmpireModules.json'

            }

            New-UDGrid -Title "Empire Config" -Headers @("version", "api_username", "install_path") -Properties @("version", "api_username", "install_path") -AutoRefresh -Endpoint {
                $JsonData = .\ReadEmpireConfig.ps1 
                If ($JsonData.version)
                {
                    $Text =  'Empire - Version: ' + ($JsonData.version) +' - User: ' + ($JsonData.api_username)  + ' - Installed: ' + ($JsonData.install_path)    
                }
                else 
                {
                    $Text = "No Empire Found - Run Config!"            
                }
                $JsonData | Out-UDGridData
            }

                
            New-UDGrid -Title "Empire Agents" -Headers @("id", "name", "checkin_time","external_ip","hostname","internal_ip","langauge", "langauge_version", "lastseen_time","listener","os_details","username") -Properties @("id", "name", "checkin_time","external_ip","hostname","internal_ip","langauge", "langauge_version", "lastseen_time","listener","os_details","username") -AutoRefresh -Endpoint {
                $JsonData = .\ReadEmpireAgents.ps1 
                $JsonData | Out-UDGridData
            }        

            New-UDGrid -Title "Empire Modules" -Headers @("Name", "Description", "Author","Language","NeedsAdmin","OpsecSafe") -Properties @("Name", "Description", "Author","Language","NeedsAdmin","OpsecSafe") -AutoRefresh -Endpoint {
                $JsonData = .\ReadEmpireModules.ps1 
                $JsonData | Out-UDGridData
            }      
            
            
    }
     
   




    ###### EMPIRE OPERATIONS!!!!!!!!!!!!!

    $Global:EmpireOperationsUDPage = New-UDPage -Name "Empire - Operations" -Icon empire -Content {
  
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

        
        
        New-UDElement -Id "CurrentAgentUDElement" -Tag "b" -Content  {"Currently Selected Agent: $Session:CurrentlySelectedAgent"}
     
        
        New-UDInput -Title "Target Agent" -Id "AgentSelectionOperations"  -Content {
            New-UDInputField -Type 'select' -Name 'EmpireAgentName' -Values $ResourcesAgentJsonContent.name -DefaultValue "NONE" -Placeholder "Select an Agent"
        
        } -Endpoint{
            $Session:CurrentlySelectedAgent = $EmpireAgentName
            Clear-UDElement -Id "CurrentAgentUDElement"
            Add-UDElement -ParentId "CurrentAgentUDElement" -Content {
                    New-UDElement -Tag "b" -Content  {"Currently Selected Agent: $Session:CurrentlySelectedAgent"}
            }
            
        }

       
        New-UDGrid -Title "Package Selection" -Headers @("Name", "Description", "Execute") -Properties @("Name", "Description", "Execute") -AutoRefresh -Endpoint {
            $JsonModuleData = .\ReadEmpireModules.ps1 
            $JsonModuleData | ForEach-Object {

            [PSCustomObject]@{
                Name = $_.Name
                Description = $_.Description
                Execute = New-UDButton -Text "Execute" -OnClick (New-UDEndpoint -Endpoint { 

                    $EmpireAgentName = $ArgumentList[0]
                    $ModuleName =  $ArgumentList[1]
                    $ModuleDescription = $ArgumentList[2]
                    
                    Show-UDModal -Content {
                        New-UDTable -Title "Strike Package Details" -Headers @("Name", "Description", "Agent") -Endpoint {
                            @{
                                'Name' = $ModuleName
                                'Description' = $ModuleDescription
                                'Agent' = $EmpireAgentName
                            } | Out-UDTableData -Property @("Name", "Description", "Agent")
                            
                        }

                        New-UDInput -Title "Execute Strike Package" -Id "AgentModuleOperations" -Content {
                           
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
                            $Text >> 'C:\Users\lee\git\bluestrike.txt'
                            $EmpireModuleExeuction = .\Tools\Empire\ExecuteModuleOnAgent.ps1 -EmpireBox $EmpireBox -EmpireToken $EmpireToken -EmpirePort $EmpirePort -AgentName $EmpireAgentName -ModuleName $ModuleName
                            New-UDInputAction -Toast $EmpireModuleExeuction

                            Clear-UDElement -Id "StrikePackageExecution"
                            Add-UDElement -ParentId "StrikePackageExecution" -Content {
                                    New-UDHtml -Markup '<b>STRIKE STATUS: <font size="3" color="red">EXECUTED</font></b>'
                            }


                           }


                           New-UDElement -Id "StrikePackageExecution" -Tag "b" -Content  {"STRIKE STATUS: DEPLOYMENT READY"}
     
                        
                    } 


                } -ArgumentList $Session:CurrentlySelectedAgent, $_.Name, $_.Description)
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


    $Global:EmpireResultsUDPage = New-UDPage -Name "Empire - Results" -Icon empire -Content {
        
        New-UDLayout -Columns 1 {
            New-UDHeading -Size 3 -Content {
                New-UDIcon -Icon money
                "    EMPIRE Agent Results"
            } 
            New-UDHeading -Text "Get Result Output Text from EMPIRE Modules" -Size 5 
        }
        
        
        ## GET AGENTS
        $ResourcesAgentsJsonFile = '.\EmpireAgents.json'

        if(Test-Path $ResourcesAgentsJsonFile)
        {
            $ResourcesAgentJsonContent = ConvertFrom-Json -InputObject (Get-Content $ResourcesAgentsJsonFile -raw)
        }

        New-UDInput -Title "Retrieve Results" -Id "AgentResultsRetrieval" -Content {
            New-UDInputField -Type 'select' -Name 'EmpireAgentName' -Values $ResourcesAgentJsonContent.name
        } -Endpoint {
            param($EmpireAgentName)

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

            
            Add-UDElement -ParentId "ExecutionResults2" -Content {
                New-UDElement -Tag "li" -Content  {New-UDPreloader}
            }            

            $EmpireResults = .\Tools\Empire\GetEmpireAgentResults.ps1 -EmpireBox $EmpireBox -EmpireToken $EmpireToken -EmpirePort $EmpirePort -AgentName $EmpireAgentName
            
            Clear-UDElement -Id "ExecutionResults2"
            ForEach($result in $EmpireResults)
            {
               

                Add-UDElement -ParentId "ExecutionResults2" -Content {
                    New-UDElement -Tag "li" -Content  {$result.results}
                }

                

            }
      
        }

        New-UDElement -Tag "ul" -Id "ExecutionResults2" -Content {
            
        }
        
    }


    $Global:AboutUDPage = New-UDPage -Name "About" -Icon question -Content {
        New-UDCard -Title "About" -Id "AboutPageCard" -Text "Hey what's up - check out ya boi: http://leealanberg.com/"
    }

        Start-UDDashboard -Port $Port -Content {
        New-UDDashboard -Title "BlueStrike" -Pages @(
            $HomeUDPage, 
            
            $Global:NetworkDiscoveryUDPage, 
            $Global:NetworkOperationsUDPage, 
            
            $Global:EmpireOperationsUDPage,
            $Global:EmpireResultsUDPage,
            $Global:EmpireConfigurationUDPage,

            $Global:AboutUDPage
            )
    }
}

