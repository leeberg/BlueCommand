function Start-BSDash {
    param(
        [Parameter(Mandatory=$true)] $EmpireServer,
        [Parameter(Mandatory=$true)] $EmpireDirectory,
        [Parameter(Mandatory=$true)] $EmpirePort,
        [Parameter(Mandatory=$true)] $BlueCommandFolder,
        [Parameter(Mandatory=$true)] $BlueCommandPort,
        [Parameter(Mandatory=$false)] $WindowsCredentialName
    )

    # This Caches the Connection Info so the other components and modules can utilze them
    $Cache:ConnectionInfo = @{
        Server = $EmpireServer
        Credential = $Credential
    }
    
    #Dashboard Port
    $Cache:BlueCommandPort = $BlueCommandPort
    
    # Empire Server
    $Cache:EmpireServer = $EmpireServer
    $Cache:EmpireDirectory = $EmpireDirectory
    $Cache:EmpirePort = $EmpirePort

    $Cache:WindowsCredentialName = $WindowsCredentialName

    $Pages = @()
    $Pages += . (Join-Path $PSScriptRoot "pages\home.ps1")

    Get-ChildItem (Join-Path $PSScriptRoot "pages") -Exclude "home.ps1" | ForEach-Object {
        $Pages += . $_.FullName
    }
    

    #### DATA FOLDER SETUP

    #Folder Pathes
    $Cache:BlueCommandFolder = $BlueCommandFolder
    $Cache:BlueCommandDataFolder = $Cache:BlueCommandFolder + '\Data'

    #File Paths
    $Cache:EmpireConfigFilePath = $Cache:BlueCommandFolder + '\Data\EmpireConfig.json'
    $Cache:EmpireModuleFilePath = $Cache:BlueCommandFolder + '\Data\EmpireModules.json'
    $Cache:EmpireAgentFilePath = $Cache:BlueCommandFolder + '\Data\EmpireAgents.json'
    $Cache:NetworkScanFilePath = $Cache:BlueCommandFolder + '\Data\NetworkScan.json'
    $Cache:BSLogFilePath = $Cache:BlueCommandFolder + '\Data\AuditLog.log'
    $Cache:BSDownloadsPath = $Cache:BlueCommandFolder + '\Data\Downloads'



    if((Test-Path -Path $Cache:BlueCommandFolder)  -eq $false){throw 'The BlueCommand Data Folder does not exist!'}
    if((Test-Path -Path $Cache:BlueCommandDataFolder) -eq $false){New-Item -Path $Cache:BlueCommandDataFolder -ItemType Directory}
    if((Test-Path -Path $Cache:BSDownloadsPath) -eq $false){New-Item -Path $Cache:BSDownloadsPath -ItemType Directory}
    if((Test-Path -Path $Cache:BSLogFilePath) -eq $false){New-Item -Path $Cache:BSLogFilePath -ItemType File}

    #Downloads Folder
    $DownloadsFolder = Publish-UDFolder -Path ($Cache:BSDownloadsPath+'\') -RequestPath '/Downloads'


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
    
    $BSEndpoints = New-UDEndpointInitialization -Module @("Modules\Empire\BlueCommandData.psm1", "Modules\Empire\BlueCommandEmpire.psm1")
    $Dashboard = New-UDDashboard -Title "BlueCommand 🌌" -Pages $Pages -EndpointInitialization $BSEndpoints -Theme $DarkDefault 
    
    Try{
        Start-UDDashboard -Dashboard $Dashboard -Port $Cache:BlueCommandPort -PublishedFolder $DownloadsFolder
    }
    Catch
    {
        Write-Error($_.Exception)
    }
    



}
