# bypassess ssl certificate errors
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

#get contributor roleId
$headers = @{
    "Authorization" = "Bearer $access_token"
    "Accept" = "application/json"
    }
$response = Invoke-WebRequest -Method GET -Headers $headers -Uri "$baseURL/api/roles?includeManifest=true&compiledRoles=true"
$responseUserContent =  echo $response.Content | ConvertFrom-Json
$roles = $responseUserContent | select _id,name | where {$_.name -eq "contributor"}
$roleId = $roles | select _id | ft -HideTableHeaders | Out-String
$contributorId = $roleId.trim()
# echo $contributorId

#### get Consumers or viewers userId's
$response1= Invoke-WebRequest -Method GET -Headers $headers -Uri $baseURL/api/users
$responseUserContent1 =  echo $response1.Content | ConvertFrom-Json
$roles1 = $responseUserContent1 | select _id,roleName | where {$_.roleName -eq "consumer"}
$roleId1 = $roles1 | select _id | ft -HideTableHeaders | Out-String
$consumerUserId = $roleId1.trim()
$consumerUserId | Out-File -FilePath ConsumerUserIDs.txt -Force

####updating consumer or viewer users using patch request
Get-Content ConsumerUserIDs.txt | foreach {
	$headers = @{
		"Authorization" = "Bearer $access_token"
		"Accept" = "application/json"
		"Content-Type"="application/json"
		}
	$body = @{
	"roleId"= "$contributorId"
	}
    $json = $body | ConvertTo-Json
	# echo "ViewerUserId: $_"
	# echo $json
    $response2= Invoke-WebRequest -Method PATCH -Headers $headers -Body $json -Uri $baseURL/api/v1/users/$_
}

# rm ConsumerUserIDs.txt