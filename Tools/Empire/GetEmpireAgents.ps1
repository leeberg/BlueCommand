Param(
    $EmpireBox = '192.168.200.108',
    $EmpireToken = 'svcx1oa9ynrqy0pc089qs4s0askox1evhk3c9k6w',
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

#Get Agents
$Agents = Invoke-WebRequest -Method Get -uri "https://$EmpireBox`:$EmpirePort/api/agents?token=$EmpireToken"
$Agents = $Agents.Content | ConvertFrom-Json

$AgentObjects = @()
ForEach($Agent in $Agents.agents)
{
    
    $AgentObject = [PSCustomObject]@{
        id = $Agent.ID
        checkin_time = $Agent.checkin_time
        external_ip = $Agent.external_ip
        hostname = $Agent.hostname
        internal_ip = $Agent.internal_ip
        langauge = $Agent.language
        langauge_version = $Agent.language_version
        lastseen_time = $Agent.lastseen_time
        listener = $Agent.listener
        name = $Agent.name
        os_details = $Agent.os_details
        username = $Agent.username
    }
    $AgentObjects = $AgentObjects + $AgentObject

}

return $AgentObjects 