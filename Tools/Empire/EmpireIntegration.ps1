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



function Get-EmpireModules
{
    param(
        $EmpireBox = '192.168.200.108',
        $EmpireToken = 'ebrg7z9snihbp0lbfe9qs0fxtwwsm44fk3waffar',
        $EmpirePort = '1337'
    )
    
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

}
