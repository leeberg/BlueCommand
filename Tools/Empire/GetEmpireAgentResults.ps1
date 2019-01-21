#https://github.com/EmpireProject/Empire/wiki/RESTful-API

Param(
    $EmpireBox = '192.168.200.108',
    $EmpireToken = 'ebrg7z9snihbp0lbfe9qs0fxtwwsm44fk3waffar',
    $EmpirePort = '1337',
    $AgentName = "8BYZEAXN"
)
#[System.Net.ServicePointManager]::ServerCertificateValidationCallback = { $true }
add-type @"
using System.Net;
using System.Security.Cryptography.X509Certificates;
public class TrustAllCertsPolicy : ICertificatePolicy {
    public bool CheckValidationResult(
        ServicePoint srvPoint, X509Certificate certificate,
        WebRequest request, int certificateProblem) {
        return true;
    }
}
"@
[System.Net.ServicePointManager]::CertificatePolicy = New-Object TrustAllCertsPolicy

$uri = 'https://'+$EmpireBox+':'+$EmpirePort+'/api/agents/'+$AgentName+'/results?token='+$EmpireToken

$AgentResults = Invoke-WebRequest -Method Get -uri $uri
$AgentResults = $AgentResults.Content | ConvertFrom-Json
$AgentResultObjects = @()
ForEach($Result in $AgentResults.results.AgentResults)
{
    
    $ResultObject = [PSCustomObject]@{
        agentname = $AgentName
        command = $Result.command 
        results = $Result.results 
    }
    $AgentResultObjects = $AgentResultObjects + $ResultObject

}

return $AgentResultObjects 