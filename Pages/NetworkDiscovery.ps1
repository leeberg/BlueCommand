New-UDPage -Name "NetworkDiscovery" -Icon search -Content {
        
    New-UDInput -Title "Discover Network Resources IPv4 Network Scan" -Id "DiscoveryInput" -Content {
        New-UDInputField -Type 'textarea' -Name 'StartAddress' -Placeholder 'Start IPv4 Address' -DefaultValue '192.168.200.1'
        New-UDInputField -Type 'textarea' -Name 'EndAddress' -Placeholder 'End IPv4 Address' -DefaultValue '192.168.200.255'
    
    } -Endpoint{
        param($StartAddress, $EndAddress)
        
        if (($StartAddress -ne '') -and ($EndAddress -ne ''))
        {
            # Do a IPV4 Scan
           # $StartAddress = '192.168.200.100'
           # $EndAddress = '192.168.200.115'

            Write-BSAuditLog -BSLogContent "Network Discovery: Starting IP Scan"

            $NetworkScanResults = .\Modules\NetworkScan\IPv4NetworkScan.ps1 -StartIPv4Address $StartAddress -EndIPv4Address $EndAddress
            
            $ScanCount = ($NetworkScanResults | measure).Count


            Write-BSAuditLog -BSLogContent "Network Discovery: IP Address Scan Complete - Found $ScanCount Resource(s)"
            
            Write-BSAuditLog -BSLogContent "Network Discovery: Starting Port Scan"
            
            $NetworkScanData = @()
            #### Data Stuff
            ForEach($Result in $NetworkScanResults)
            {
                Write-BSAuditLog -BSLogContent ('Network Discovery: Port Scanning: ' + $Result.Hostname)
                $EmpirePortOpen = 'No'
                
                $PortScanResults = .\Modules\PortScan\IPv4PortScan.ps1 -ComputerName $Result.IPv4Address.IPAddressToString -StartPort 1337 -EndPort 1337
 
                if($PortScanResults)
                {
                    $EmpirePortOpen = 'Yes'
                }
                else
                {
                    $EmpirePortOpen = 'No'
                }

                if($Result.Hostname)
                {
                    $HostNameFormat = $Result.Hostname
                }
                else
                {
                    $HostNameFormat = 'Unknown'
                }

                $NetworkScanData = $NetworkScanData +[PSCustomObject]@{
                    IPv4 = ($Result.IPv4Address.IPAddressToString);
                    Status = ($Result.Status);
                    Hostname = ($HostNameFormat);
                    EmpireServer = ($EmpirePortOpen);
                    ScanTime = (Get-Date);
                }
               
                
            }

            Write-BSAuditLog -BSLogContent "Network Discovery: Port Scan Complete"

            # Output a new Grid based on that info
            New-UDInputAction -Content @(
            
                New-UDGrid -Title "Network Disovery Results" -Headers @("IPv4", "Status", "Hostname","EmpireServer") -Properties @("IPv4", "Status", "Hostname","EmpireServer") -Endpoint {
                    $NetworkScanData | Select-Object -Property IPv4,Status,Hostname,EmpireServer | Out-UDGridData
                }
        
            )

            Write-BSAuditLog -BSLogContent ('Network Discovery: Writing Network Discovery Data')
            # Save to JSON File            
            Write-BSNetworkScanData -BSObjectData $NetworkScanData
        }
        else {
            New-UDInputAction -Toast "Fill all required fields!"
        }

    }
}
