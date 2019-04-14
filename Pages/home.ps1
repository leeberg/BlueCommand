

New-UDPage -Name "Home" -Icon home -Endpoint {
            
    New-UDRow -Columns {
        
        New-UDColumn -Size 2 {         
            New-UDCard -Id 'crd_home1' -Title "" -Content{
                New-UDButton -Id "BTN_GotoNetworkDiscovery" -Icon search -Text "Network Disc" -OnClick {                                     
                    $ButtonVar = Invoke-UDRedirect -Url  "/Network---Discovery" 
                }
            }     
        }
        
        New-UDColumn -Size 2 {         
            New-UDCard -Id 'crd_home1' -Title "" -Content{
                New-UDButton -Id "BTN_GotoNetworkOperations" -Icon expand -Text "Network Ops" -OnClick {                                     
                    $ButtonVar = Invoke-UDRedirect -Url  "/Network--Operations" 
                }
            }     
        } 

        New-UDColumn -Size 2 {         
            New-UDCard -Id 'crd_home1' -Title ""  -Content{
                New-UDButton -Id "BTN_GotoEmpireOperations" -Icon plane -Text "Empire Strike" -OnClick {                                 
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
                New-UDButton -Id "BTN_GotoEmpireConfiguration" -Icon empire -Text "Empire Config" -OnClick {                                     
                    $ButtonVar = Invoke-UDRedirect -Url  "/Empire---Configuration" 
                }
            }
        }   
         
        New-UDColumn -Size 2 {         
            New-UDCard -Id 'crd_home1' -Title "" -Content{
                New-UDButton -Id "BTN_GotoHelpAbout" -Icon question -Text "Help" -OnClick {                                     
                    $ButtonVar = Invoke-UDRedirect -Url  "/About" 
                }
            }     
        }


        
       
        
    }
    

    ### CARD COUNTS
    $EmpireAgentsJsonData = Get-BSEmpireAgentData
    $EmpireModulesJsonData = Get-BSEmpireModuleData
    $NetworkResourcesJsonData = Get-BSNetworkScanData

    $NetworkResourcesCount = ($NetworkResourcesJsonData | Measure | Select-Object Count).Count
    $EmpireAgentsCount = ($EmpireAgentsJsonData | Measure | Select-Object Count).Count
    $EmpireModuleCount = $EmpireModulesJsonData.Count
    


    New-UDRow -Columns {
        

        New-UDColumn -Size 2 {    

            New-UDCounter -Title "Network Resources Discovered" -Endpoint {
                $NetworkResourcesCount | ConvertTo-Json
            } -FontColor "black"

        }

        New-UDColumn -Size 2 {    

            New-UDCounter -Title "Modules Currently Loaded" -Endpoint {
                $EmpireModuleCount | ConvertTo-Json
            } -FontColor "black"

        }
        
        New-UDColumn -Size 2 {    

            New-UDCounter -Title "Agents Currently Active" -Endpoint {
                $EmpireAgentsCount | ConvertTo-Json
            } -FontColor "black"

        }

        New-UDColumn -Size 2 {    

            New-UDCounter -Title "Strike Packages Deployed" -Endpoint {
                18 | ConvertTo-Json
            } -FontColor "black"

        }

        New-UDColumn -Size 2 {    

            New-UDCounter -Title "Agent Results Downloads" -Endpoint {
                5 | ConvertTo-Json
            } -FontColor "black"

        }


        New-UDColumn -Size 2 {    

            New-UDCard -Title 'Operation Status' -Content {
                New-UDParagraph -Text 'ACTIVE
                '
            } 
        

        }


    }

    
    $JsonData = Get-BSNetworkScanData
    New-UDGrid -Title "Known Resources" -Headers @("HostName", "IPv4", "Status","Computer") -Properties @("HostName", "IPv4", "Status","Computer") -Endpoint {
        
            $JsonData | Out-UDGridData
    }


    $JsonData = Get-BSEmpireAgentData
    New-UDGrid -Title "Empire Agents" -Headers @("Name", "checkin_time","lastseen_time","external_ip","hostname","listener","OS","username") -Properties @("name", "checkin_time","lastseen_time","external_ip","hostname","listener","os_details","username") -AutoRefresh -Endpoint {
            
            $JsonData | Out-UDGridData
    }  
    
    #>      
        
    
}
