 # Operations Page
New-UDPage -Name "Network - Operations" -Icon fighter_jet -RefreshInterval 5 -Content {
    
    $NetworkResources = Get-BSNetworkScanData
    
    New-UDInput -Title "Operations" -Id "HackForm" -Content {
        New-UDInputField -Type 'select' -Name 'Computer' -Values $NetworkResources.Hostname
        New-UDInputField -Type 'select' -Name 'Operation' -Values @("Ping") -DefaultValue "Ping"
        New-UDInputField -Type 'textarea' -Name 'Notes' -Placeholder 'Notes'
    } -Endpoint {
        param($Computer, $Operation, $Notes)
        $MessageTimestamp = Get-Date
        

        IF($Operation -eq 'Ping')
        {
            Write-BSAuditLog -BSLogContent ('Network Operations: Attempting Network Operation PING on: ' + $Computer + ' with notes: ' + $Notes)

            $Pingas = Test-Connection -ComputerName $Computer
            
            New-UDInputAction -Content @(
                                
                New-UDGrid -Title "Ping Result(s)"  -Headers @("Source", "IPV4Address","IPV6Address","Time(ms)") -Properties @("Source", "IPV4Address","IPV6Address","Time(ms)") -Endpoint {
                    $Pingas | Select-Object -Property @{Name="Source"; Expression = {$_.PSComputerName}},@{Name="IPV4Address"; Expression = {$_.IPv4Address.IPAddressToString}},@{Name="IPV6Address"; Expression = {$_.IPv6Address.IPAddressToString}}, @{Name="Time(ms)"; Expression = {$_.ResponseTime}} | Out-UDGridData
                    Write-BSAuditLog -BSLogContent ('Network Operations: Ping Attempt on: ' + $Computer + ' Completed')
                }

            )
        }
        else {
            New-UDInputAction -Toast "Operation $Operation is not implemented!"    
        }

    }
}
