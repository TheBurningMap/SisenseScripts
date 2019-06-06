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
$file_content = Get-Content "dashboards.conf"
$file_content = $file_content -join [Environment]::NewLine
$configuration = ConvertFrom-StringData($file_content)
$hostName = $configuration.'hostName'

$baseURL=""
$access_token=""
$headers=""
. .\hosts.ps1 $hostName

$headers = @{
    "Accept" = "application/json"
	"Authorization" = "Bearer $access_token"
	}

$workspace = Get-Location
cd $workspace
If((test-path $workspace\NonAdminDashboards.txt))
{
      Remove-Item -force -confirm:$false $workspace\NonAdminDashboards.txt
}

If((test-path $workspace\superUser.json))
{
      Remove-Item -force -confirm:$false $workspace\superUser.json
}

If((test-path $workspace\User.json))
{
      Remove-Item -force -confirm:$false $workspace\User.json
}

#get super user owner id
$superuser = Invoke-WebRequest -Method GET -Headers $headers -Uri $baseURL/api/users
$superuserRes = echo $superuser.Content | ConvertFrom-Json
$superuserRole = $superuserRes | Select-Object _id,roleName | where-object {$_.roleName -eq "super"}
$super = $superuserRole | select _id | ft -HideTableHeaders | Out-String
$superuserId = $super.trim()
echo "superuserId:$superuserId"
$superUserBody =@"
{
	"ownerId": "$superuserId",
	"originalOwnerRule": "edit"
}
"@
echo $superUserBody | Out-File superUser.json

#get all dashboards OIDs
$response1 = Invoke-WebRequest -Method GET -Headers $headers -Uri $baseURL/api/v1/dashboards/admin
$res1 = echo $response1.Content | ConvertFrom-Json
$oidS = $res1.oid | sort | get-unique

#check all oids and which are not shared with admin
#if any oid is not shared, preserver there userID and dashboard ID and changed the owner to Super User

echo "changing all the non-admin dashborads to superUser which are not shared already"
foreach($OID in $oidS)
{
	if($OID)
	{
		$responsereq = Invoke-WebRequest -Method GET -Headers $headers -Uri $baseURL/api/v1/dashboards/$OID/exists
		$check = $responsereq | ConvertFrom-Json
		$dashboard = $check.exists
		if ($dashboard -ne "True")
		{
			$LIST_DASHBOARDS = $res1 | Select-Object -Property oid,userId,owner,title | where-object {$_.oid -eq $OID -And $_.userId -eq $_.owner }
			$userId_raw = $LIST_DASHBOARDS | select userId | ft -HideTableHeaders | Out-String
			$userId = $userId_raw.trim()
			echo "$OID,$userId" | Out-File -append NonAdminDashboards.txt
			#Change owner of Dashboard to Super User
			$headers = @{
						  "Authorization" = "Bearer $access_token"
						  "Accept" = "application/json"
						  "Content-Type"="application/json"
						}
			$body = Get-Content -Path superUser.json -Raw
			try{
					$owner_admin = Invoke-WebRequest -Method POST -Headers $headers -Body $body -Uri $baseURL/api/v1/dashboards/$OID/admin/change_owner
			}catch  { "WARN: failed to process $OID oid " }
		}
		$OID=""
		$userId=""
	}
}


# #export all dashboards
# echo "export all dashboards"

# . .\pushSpecificDash.ps1 $hostName
# . .\getSisenseDash.ps1 $hostName




#revert back non admin dashboards back to its user id
# $userResponse = Read-Host -Prompt "`nDo you want to revert owners back to its  original one(yes/no)"

Get-Content $workspace\NonAdminDashboards.txt | foreach {
	$OID = $_.Split(',')[0]
	$userId = $_.Split(',')[1]
	If((test-path $workspace\User.json))
	{
		Remove-Item -force -confirm:$false $workspace\User.json
	}
	$UserBody =@"
{
"ownerId": "$userId",
"originalOwnerRule": "edit"
}
"@
	echo $UserBody | Out-File User.json
	$headers = @{
	                  "Authorization" = "Bearer $access_token"
                      "Accept" = "application/json"
                      "Content-Type"="application/json"
                    }
	# $body = Get-Content -Path User.json -Raw
	if($OID)
	{
		try{
				$owner_admin = Invoke-WebRequest -Method POST -Headers $headers -Body $UserBody -Uri $baseURL/api/v1/dashboards/$OID/admin/change_owner
		} catch  { "WARN: failed to process $OID oid " }
		$UserBody = ""
		$OID = ""
		$userId = ""
	}
}




If((test-path $workspace\NonAdminDashboards.txt))
{
      Remove-Item -force -confirm:$false $workspace\NonAdminDashboards.txt
}

If((test-path $workspace\superUser.json))
{
      Remove-Item -force -confirm:$false $workspace\superUser.json
}
If((test-path $workspace\User.json))
{
      Remove-Item -force -confirm:$false $workspace\superUser.json
}