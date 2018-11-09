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


#Get Configuration
$ConfigurationInformation = Invoke-WebRequest -Method Get -uri "https://$EmpireBox`:$EmpirePort/api/config?token=$EmpireToken"
$ConfigurationInformation = $ConfigurationInformation.Content | ConvertFrom-Json
$ConfigurationInformation = $ConfigurationInformation.config


$ConfigurationInformationObject = [PSCustomObject]@{
    api_username = $ConfigurationInformation.api_username
    install_path = $ConfigurationInformation.install_path
    version    = $ConfigurationInformation.version
}

return $ConfigurationInformationObject 