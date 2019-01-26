 # Operations Page
New-UDPage -Name "Network - Operations" -Icon fighter_jet -RefreshInterval 5 -Content {
        
    $ResourcesJsonFile = '..\scan.json'

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
