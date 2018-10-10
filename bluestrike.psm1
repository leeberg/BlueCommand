
function get-Data()
{
    $Data = @(
        [PSCustomObject]@{Animal="Frog";Order="Anura"}
        [PSCustomObject]@{Animal="Tiger";Order="Carnivora"}
        [PSCustomObject]@{Animal="Bat";Order="Chiroptera"}
        [PSCustomObject]@{Animal="Fox";Order="Carnivora"}
    )

    return $Data
}


function Start-BSDash {

    #### SETUP STUFF
    param($Port = 10000) 
    



    #### Data Stuff
    $Data = @()

    $IpAddresses = Get-NetIPAddress
    foreach($IP in $IpAddresses)
    {
                                                                                                                                                                                       
        $Data = $Data +[PSCustomObject]@{External=($IP.IPAddress);Internal=($IP.IPAddress);User=(New-UDLink -Text "User" -Url "https://en.wikipedia.org/wiki/Frog");Computer=(New-UDLink -Text "Computer" -Url "https://en.wikipedia.org/wiki/Frog");Note="Fuk u";pid=(Get-Random -Minimum 1 -Maximum 9999);last="99s"}
        #[PSCustomObject]@{External="Frog";Order="Anura";Article=(New-UDLink -Text "Wikipedia" -Url "https://en.wikipedia.org/wiki/Frog")}
        

    }
                 
    

$dashboard = New-UDDashboard -Title "BlueStrike" -Content {
        
        New-UDGrid -Title "Dingers" -Headers @("External", "Internal", "User","Computer","Note","pid","last") -Properties @("External", "Internal", "User","Computer","Note","pid","last") -Endpoint {
            $Data | Out-UDGridData
        }
      
    

        New-UDInput -Title "Operations" -Id "HackForm" -Content {
                New-UDInputField -Type 'select' -Name 'Computer' -Values $Data.External
                New-UDInputField -Type 'select' -Name 'Operation' -Values @("Ping", "Spray", "UBA", "MimiKatz")
                New-UDInputField -Type 'textarea' -Name 'AdditionalNotes' -Placeholder 'Additional Notes'
        } -Endpoint {
                param($Computer, $Operation, $AdditionalNotes)
                $MessageTimestamp = Get-Date
                

                IF($Operation -eq 'Ping')
                {
                    $Pingas = Test-Connection -ComputerName $Computer
                    
                    New-UDInputAction -Content @(
                        New-UDCard -Title "Ping Result" -Text ($Pingas | Out-String)
                    )
                }
                else {
                    New-UDInputAction -Toast "Operation $Operation is not implemented!"    
                }

        }



    
}

Start-UDDashboard -Port $Port -Dashboard $dashboard -AllowHttpForLogin:$AllowHttpForLogin
}

