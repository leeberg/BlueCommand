function Start-BSDash {
    param(
        [Parameter(Mandatory=$true)] $EmpireServer,
        [Parameter(Mandatory=$true)] $BlueStrikeFolder
    )

    # This Caches the Connection Info so the other components and modules can utilze them
    $Cache:ConnectionInfo = @{
        Server = $EmpireServer
        Credential = $Credential
    }

    # Empire Server
    $Cache:EmpireServer = $EmpireServer

    $Pages = @()
    $Pages += . (Join-Path $PSScriptRoot "pages\home.ps1")

    Get-ChildItem (Join-Path $PSScriptRoot "pages") -Exclude "home.ps1" | ForEach-Object {
        $Pages += . $_.FullName
    }
    

    #### DATA FOLDER SETUP

    #Folder Pathes
    $Cache:BlueStrikeFolder = $BlueStrikeFolder
    $Cache:BlueStrikeDataFolder = $Cache:BlueStrikeFolder + '\Data'

    #File Paths
    $Cache:EmpireConfigFilePath = $Cache:BlueStrikeFolder + '\Data\EmpireConfig.json'
    $Cache:EmpireModuleFilePath = $Cache:BlueStrikeFolder + '\Data\EmpireModules.json'
    $Cache:EmpireAgentFilePath = $Cache:BlueStrikeFolder + '\Data\EmpireAgents.json'
    $Cache:NetworkScanFilePath = $Cache:BlueStrikeFolder + '\Data\NetworkScan.json'
    $Cache:BSLogFilePath = $Cache:BlueStrikeFolder + '\Data\AuditLog.log'


    if((Test-Path -Path $Cache:BlueStrikeFolder)  -eq $false){throw 'The BlueStrike Data Folder does not exist!'}
    if((Test-Path -Path $Cache:BlueStrikeDataFolder) -eq $false){New-Item -Path $Cache:BlueStrikeDataFolder -ItemType Directory}
    if((Test-Path -Path $Cache:BSLogFilePath) -eq $false){New-Item -Path $Cache:BSLogFilePath -ItemType File}

    #### THEME    
    
    $DarkDefault = New-UDTheme -Name "Basic" -Definition @{
            UDDashboard = @{
                BackgroundColor = "#393F47"
                FontColor = "#FFFFFF"
            }
            UDNavBar = @{
                BackgroundColor =  "#272C33"
                FontColor = "#FFFFFF"
            }
            UDFooter = @{
                BackgroundColor =  "#272C33"
                FontColor = "#FFFFFF"
            }
            UDCard = @{
                BackgroundColor = "#272C33"
                FontColor = "#FFFFFF"
            }
            UDChart = @{
                BackgroundColor = "#272C33"
                FontColor = "#FFFFFF"
            }
            UDMonitor = @{
                BackgroundColor = "#272C33"
                FontColor = "#FFFFFF"
            }
            UDTable = @{
                BackgroundColor = "#272C33"
                FontColor = "#FFFFFF"
            }
            UDGrid = @{
                BackgroundColor = "#272C33"
                FontColor = "#FFFFFF"
            }
            UDCounter = @{
                BackgroundColor = "#272C33"
                FontColor = "#FFFFFF"
            }
            UDInput = @{
                BackgroundColor = "#272C33"
                FontColor = "#FFFFFF"
            }
    }
    

    $BSEndpoints = New-UDEndpointInitialization -Module @("Modules\Empire\BlueStrikeData.psm1", "Modules\Empire\BlueStrikeEmpire.psm1")
    $Dashboard = New-UDDashboard -Title "BlueStrike" -Pages $Pages -EndpointInitialization $BSEndpoints -Theme $DarkDefault
    
    Try{
 
        Start-UDDashboard -Dashboard $Dashboard -Port 10000
      
    }
    Catch
    {
        Write-Error($_.Exception)
        Write-BSAuditLog -BSLogContent "BlueStrike Failed to Start!"
    }
    



}

function Start-BSAPI{

    ### Haven't messed around with this at all
    ### Next Step to replace module calls with API Calls?

    $Endpoints = @()

    $Endpoints += New-UDEndpoint -url 'GetEmpireModules' -Endpoint {
        Get-BSEmpireModuleData | ConvertTo-Json
        
    }

    Start-UDRestApi -Endpoint $Endpoints -Port 10001 -AutoReload




}