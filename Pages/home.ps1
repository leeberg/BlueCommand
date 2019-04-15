

New-UDPage -Name "Home" -Icon home -Endpoint {

    ### CARD COUNTS
    $EmpireAgentsJsonData = Get-BSEmpireAgentData
    $EmpireModulesJsonData = Get-BSEmpireModuleData
    $NetworkResourcesJsonData = Get-BSNetworkScanData

    $NetworkResourcesCount = ($NetworkResourcesJsonData | Measure | Select-Object Count).Count
    $EmpireAgentsCount = ($EmpireAgentsJsonData | Measure | Select-Object Count).Count
    $EmpireModuleCount = $EmpireModulesJsonData.Count
    


    New-UDRow -Columns {
        

        New-UDColumn -Size 2 {    

            New-UDCounter -Title "Empire Modules" -BackgroundColor '#4C9BF3' -FontColor '#FFFFFF' -Endpoint {
                $EmpireModuleCount | ConvertTo-Json
            }

        }
        
        New-UDColumn -Size 2 {    

            New-UDCounter -Title "Active Agents" -BackgroundColor '#4CC6DB' -FontColor '#FFFFFF' -Endpoint {
                $EmpireAgentsCount | ConvertTo-Json
            }

        }

        New-UDColumn -Size 2 {    

            New-UDCounter -Title "Agent Files" -BackgroundColor '#7561F1' -FontColor '#FFFFFF' -Endpoint {
                Get-BSDownloadsCount | ConvertTo-Json
            }

        }
        <#
        New-UDColumn -Size 2 {    

            New-UDCounter -Title "Agent Files Downloaded" -BackgroundColor '#F2496A' -FontColor '#FFFFFF' -Endpoint {
                Get-BSDownloadsCount | ConvertTo-Json
            }

        }
        #>


    }

    New-UDTable -Title "Existing Empire Instance" -Id "ExistingEmpireInstance" -Headers @("Empire IP","Version", "Path", "Sync Time")  -Endpoint {
        $JsonData = Get-BSEmpireConfigData 
        $JsonData | Out-UDTableData -Property @("empire_host","version", "install_path", "sync_time")
    }


    $JsonData = Get-BSEmpireAgentData
    New-UDGrid -Title "Empire Agents" -Headers @("Name", "Created", "Last Seen","External IP","Hostname","Listener","OS","Username") -Properties @("name", "checkin_time","lastseen_time","external_ip","hostname","listener","os_details","username") -AutoRefresh -Endpoint {
            
            $JsonData | Out-UDGridData
    }  
    
    #>      
        
    
}
