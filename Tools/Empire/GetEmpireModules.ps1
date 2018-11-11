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
$Modules = Invoke-WebRequest -Method Get -uri "https://$EmpireBox`:$EmpirePort/api/modules?token=$EmpireToken"
$Modules = $Modules.Content | ConvertFrom-Json

$ModuleObjects = @()
ForEach($Module in $Modules.modules)
{
    
    $ModuleObject = [PSCustomObject]@{
        Name = $Module.Name
        Author = $Module.Author
        Comments = $Module.Comments
        Description = $Module.Description
        Language = $Module.Language
        NeedsAdmin = $Module.NeedsAdmin
        OpsecSafe = $Module.OpsecSafe
        options = $Module.options
    }
    $ModuleObjects = $ModuleObjects + $ModuleObject

}

return $ModuleObjects 