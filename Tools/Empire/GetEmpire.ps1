Param(
    $EmpireBox = '192.168.200.108',
    $EmpireToken = '6jq0or8kcawfi4vjyktehwuqugv7uhxes04mrqkq',
    $EmpirePort = '1337'
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


#Get Version
$Verison = Invoke-WebRequest -Method Get -uri "https://$EmpireBox`:$EmpirePort/api/version?token=$EmpireToken"
$Verison = $Verison.Content | ConvertFrom-Json
$Verison = $Verison.version

#Get Listeners
$Listeners = Invoke-WebRequest -Method Get -uri "https://$EmpireBox`:$EmpirePort/api/listeners?token=$EmpireToken"
$Listeners = $Listeners.Content | ConvertFrom-Json

#Get Agents
$Agents = Invoke-WebRequest -Method Get -uri "https://$EmpireBox`:$EmpirePort/api/agents?token=$EmpireToken"
$Agents = $Agents.Content | ConvertFrom-Json
ForEach($Agent in $Agents.agents)
{
    Write-Host $Agent.
}


#Start-Command 

#& "curl --insecure -i https://$EmpireBox`:$EmpirePort/api/version?token=$EmpireToken"

