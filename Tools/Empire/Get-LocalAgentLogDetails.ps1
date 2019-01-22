
Param(
    $DownloadFolder = 'C:\Users\lee\Desktop\bluestriketesting\',
    $EmpireAgentName = "8BYZEAXN"
)

$LocalAgentDownloadFolder = $DownloadFolder + $EmpireAgentName

$TimeStampRegex = '\d\d\d\d-\d\d-\d\d \d\d:\d\d:\d\d :'  #LOL - TODO wtf is this?


IF(Test-Path $LocalAgentDownloadFolder)
{
    $AgentLogContent = Get-Content -Path ($LocalAgentDownloadFolder + '\agent.log')
    $AgentResultObjects = @()
    $ObjectData = "";
    ForEach($Line in $AgentLogContent)
    {
        if($Line -match $TimeStampRegex)
        {
         
            IF($ObjectData -ne "")
            {
                $CompleteObjectData = $ObjectData
                $ResultObject.Message = $CompleteObjectData;
                $AgentResultObjects = $AgentResultObjects + $ResultObject
                $ObjectData = ""
            }

            $ResultObject = [PSCustomObject]@{
                TimeStamp = $Line
                Message = "test"
            }

        }
        else 
        {
            $ObjectData = $ObjectData + $Line;
          
        }

    }


    
}

<#
foreach ($object in $AgentResultObjects)
{
    $object
}
#>

Return $AgentResultObjects







