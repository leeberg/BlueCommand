#https://github.com/EmpireProject/Empire/wiki/RESTful-API

Param(
    $EmpireBox = '192.168.200.108',
    $EmpireToken = 'y6v5vpa8cyze8iz2co7b0i4abtfxne90u3imq52e',
    $EmpirePort = '1337',
    $AgentName = "MEHZGVRB",
    $Options = "",
    $ReportType  =  "result"  #task, result, checkin
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


### AGENT - NOT WORKING
$uri = 'https://'+$EmpireBox+':'+$EmpirePort+'/api/reporting/agent/'+$AgentName+'?token='+$EmpireToken

### ALL - WORKING
#$uri = "https://$EmpireBox`:$EmpirePort/api/reporting?token="+$EmpireToken

### TYPE
$uri = 'https://'+$EmpireBox+':'+$EmpirePort+'/api/reporting/type/'+$ReportType+'?token='+$EmpireToken


$uri
$Reports = Invoke-WebRequest -Method Get -uri $uri
$Reports = $Reports.Content | ConvertFrom-Json
$ReportObjects = @()
ForEach($Report in $Reports.reporting)
{
    
    $ReportObject = [PSCustomObject]@{
        id = $Report.ID
        agentname = $Report.agentname
        event_type = $Report.event_type
        message = $Report.message
        timestamp = $Report.timestamp
 
    }
    $ReportObjects = $ReportObjects + $ReportObject

}

return $ReportObjects 