Add-Type @"
    using System;
    using System.Net;
    using System.Net.Security;
    using System.Security.Cryptography.X509Certificates;
    public class ServerCertificateValidationCallback
    {
        public static void Ignore()
        {
            ServicePointManager.ServerCertificateValidationCallback += 
                delegate
                (
                    Object obj, 
                    X509Certificate certificate, 
                    X509Chain chain, 
                    SslPolicyErrors errors
                )
                {
                    return true;
                };
        }
    }
"@
 
[ServerCertificateValidationCallback]::Ignore();
$hostName=$args[0]
. .\hosts.ps1 $hostName
$workspace=Get-Location

$headers = @{
    "Authorization" = "Bearer $access_token"
    "Accept" = "application/json"
    }
$response = Invoke-WebRequest -Method GET -Headers $headers -Uri "$baseURL/api/roles?includeManifest=true&compiledRoles=true"
$responseUserContent =  echo $response.Content | ConvertFrom-Json
$roles = $responseUserContent | select _id,name | where {$_.name -eq "contributor"}
$roleId = $roles | select _id | ft -HideTableHeaders | Out-String
$contributorId = $roleId.trim()
echo "contributorId:$contributorId"

echo "enabling dashboard export_dash and edit_script permissions to true"
$dashboards =@"
{
    "export_dash":true,
	"edit_script":true
}
"@
echo $dashboards | Out-File dashboards.json
$headers = @{
				"Authorization" = "Bearer $access_token"
				"Accept" = "application/json"
				"Content-Type"="application/json"
		    }
$body = Get-Content -Path dashboards.json -Raw	
$response2= Invoke-WebRequest -Method POST -Headers $headers -Body $body -Uri "$baseURL/api/roles/$contributorId/manifest/%2Fdashboards"

echo "enabling widget edit_script permissions to true"
$widgets =@"
{
	"edit_script":true
}
"@
echo $widgets | Out-File widgets.json
$body1 = Get-Content -Path widgets.json -Raw
$response3= Invoke-WebRequest -Method POST -Headers $headers -Body $body1 -Uri "$baseURL/api/roles/$contributorId/manifest/%2Fwidgets"

If((test-path $workspace\dashboards.json))
{
      Remove-Item -force -confirm:$false $workspace\dashboards.json
}
If((test-path $workspace\widgets.json))
{
      Remove-Item -force -confirm:$false $workspace\widgets.json
}