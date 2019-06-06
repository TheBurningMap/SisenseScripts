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
$user=$args[0]
$file_content = Get-Content "dashboards.conf"
$file_content = $file_content -join [Environment]::NewLine
$configuration = ConvertFrom-StringData($file_content)
# $gitrepo = $configuration.'gitrepo'
# $gitbranch = $configuration.'gitbranch'
$hostName = $configuration.'hostName'
# $gitfolder = $configuration.'gitfolder'


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
# If((test-path $workspace\new.txt))
# {
      # Remove-Item -force -confirm:$false $workspace\new.txt
# }

# If((test-path $workspace\superUser.json))
# {
      # Remove-Item -force -confirm:$false $workspace\superUser.json
# }

# If((test-path $workspace\User.json))
# {
      # Remove-Item -force -confirm:$false $workspace\User.json
# }


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

# $headers = @{
    # "Accept" = "application/json"
	# "Authorization" = "Bearer $access_token"
	# }

$response1 = Invoke-WebRequest -Method GET -Headers $headers -Uri $baseURL/api/v1/dashboards/admin
# $response1 = Invoke-WebRequest -Method GET -Headers $headers -Uri https://sand007.insights.health.ge.com:8943/api/v1/dashboards/admin
$response2 = echo $response1.Content | ConvertFrom-Json
$response3 = $response2 | Select-Object oid,userId,owner,title | where-object {$_.userId -eq "$user"}
# $response3 = $response2 | Select-Object oid,userId,owner,title | where-object {$_.owner -eq "$user"}
$response4 = $response3 | select oid | ft -HideTableHeaders | Out-String
$response5 = $response4.trim() | sort | get-unique
$as =  $response5 | Out-File new.txt

# Out-File new.txt
# $response6 = $response3 | select oid,userId | ft -HideTableHeaders | Out-String
# $response7 = $response6.trim() | Out-File newUser.txt

Get-Content new.txt | foreach {

# foreach($OID in $response5) {
# {
	# if($OID)
	# {
		# $responsereq = Invoke-WebRequest -Method GET -Headers $headers -Uri $baseURL/api/v1/dashboards/$_/exists
		# $check = $responsereq | ConvertFrom-Json
		# $dashboard = $check.exists
		# if ($dashboard -ne "True")
		# {
			# $LIST_DASHBOARDS = $response2 | Select-Object -Property oid,userId,owner,title | where-object {$_.oid -eq $OID -And $_.userId -eq $_.owner }
			# $LIST_DASHBOARDS = $response2 | Select-Object -Property oid,userId,owner,title | where-object {$_.userId -eq "$user"}
			# $userId_raw = $LIST_DASHBOARDS | select userId | ft -HideTableHeaders | Out-String
			# $userId = $userId_raw.trim()
			# echo "$OID,$userId" | Out-File NonAdminDashboards.txt
			# echo "$OID,$userId" | Out-File -append NonAdminDashboards.txt
			
			# $res7 = $response2 | Select-Object oid,userId,owner,title | where-object {$_.userId -eq "$user"}
			# $response6 = $res7 | select userId | ft -HideTableHeaders | Out-String
            # $userId = $response6.trim() 
			# echo "$OID,$userId" | Out-File -append newUser.txt
			#Change owner of Dashboard to Super User
			$headers = @{
						  "Authorization" = "Bearer $access_token"
						  "Accept" = "application/json"
						  "Content-Type"="application/json"
						}
			$body = Get-Content -Path superUser.json -Raw
			try{
					$owner_admin = Invoke-WebRequest -Method POST -Headers $headers -Body $body -Uri $baseURL/api/v1/dashboards/$_/admin/change_owner
			}catch  { "WARN: failed to process $_ oid " }
		# }
		# $OID=""
		# $userId=""
	# }
}

echo "Exporting dashboards"
. .\getSisenseDash.ps1 $hostName

# revert back non admin dashboards back to its user id

echo "reverting"
Get-Content $workspace\new.txt | foreach {
	# $OID = $_.Split(',')[0]
	# $userId = $_.Split(',')[1]
	# If((test-path $workspace\User.json))
	# {
		# Remove-Item -force -confirm:$false $workspace\User.json
	# }
	$UserBody =@"
{
"ownerId": "$user",
"originalOwnerRule": "edit"
}
"@
	echo $UserBody | Out-File User.json
	$headers = @{
	                  "Authorization" = "Bearer $access_token"
                      "Accept" = "application/json"
                      "Content-Type"="application/json"
                    }
					$body = Get-Content -Path User.json -Raw
	# if($OID)
	# {
		try{
				$owner_admin = Invoke-WebRequest -Method POST -Headers $headers -Body $body -Uri $baseURL/api/v1/dashboards/$_/admin/change_owner
		} catch  { "WARN: failed to process $_ oid " }
		# $UserBody = ""
		# $OID = ""
		# $userId = ""
	# }
}




# If((test-path $workspace\new.txt))
# {
      # Remove-Item -force -confirm:$false $workspace\new.txt
# }

# If((test-path $workspace\superUser.json))
# {
      # Remove-Item -force -confirm:$false $workspace\superUser.json
# }

# If((test-path $workspace\User.json))
# {
      # Remove-Item -force -confirm:$false $workspace\User.json
# }






















# . .\folderExport.ps1 $hostName

# If((test-path $workspace\NonAdminDashboards.txt))
# {
      # Remove-Item -force -confirm:$false $workspace\NonAdminDashboards.txt
# }

# If((test-path $workspace\superUser.json))
# {
      # Remove-Item -force -confirm:$false $workspace\superUser.json
# }












# get access_token
# $headers = @{
    # "Accept" = "application/json"
    # "Content-Type"="application/x-www-form-urlencoded"
    # }
	
# $body = @{
	# "username" = "morpheus.internal.pm@ge.com"
	# "password" = "M0rpheusPM@123"
	# }

# $response = Invoke-WebRequest -Method POST -Headers $headers -Body $body -Uri https://sand007.insights.health.ge.com:8943/api/v1/authentication/login

# $responseContent = echo $response.Content | ConvertFrom-Json

# $access_token = echo $responseContent.access_token

# echo $access_token






# #get groupid for 'Everyone'

# $headers = @{
    # "Authorization" = "Bearer $access_token"
    # "Accept" = "application/json"
    # }
	
# $response1 = Invoke-WebRequest -Method GET -Headers $headers -Body $body -Uri https://sand007.insights.health.ge.com:8945/api/v1/groups?name=everyone

# $responseUserContent =  echo $response1.Content | ConvertFrom-Json

# $group_Id = echo $responseUserContent._id

# echo $group_Id

# # $response1 = Invoke-WebRequest -Method GET -Headers $headers -Body $body -Uri https://sand007.insights.health.ge.com:8945/api/v1/users?userName=view.cpm%40ge.com



# #get current shares for the dashboard

# $headers = @{
    # "Authorization" = "Bearer $access_token"
    # "Accept" = "application/json"
    # }
	

# $response2 = Invoke-WebRequest -Method GET -Headers $headers -Body $body -Uri https://sand007.insights.health.ge.com:8945/api/v1/dashboards/5a69082ef1095d4419000013/shares

# $responseDashContent = echo $response2.Content 

# echo $responseDashContent

# # $response2 = Invoke-WebRequest -Method GET -Headers $headers -Body $body -Uri https://sand007.insights.health.ge.com:8945/api/v1/dashboards/5a7ca00732a2017c3d000033


# # Share the dashboard with the group by updating the shares of the dashboard

# $headers = @{
    # "Authorization" = "Bearer $access_token"
    # "Accept" = "application/json"
	# "Content-Type"="application/json"
    # }
	
# $body = Get-Content -Path Test_Template.json -Raw



# $response3 = Invoke-WebRequest -Method PATCH -Headers $headers -Body $body -Uri https://sand007.insights.health.ge.com:8945/api/v1/dashboards/5a69082ef1095d4419000013

# #Publish dashboard for the group


# $headers = @{
    # "Authorization" = "Bearer $access_token"
    # "Accept" = "application/json"
	# "Content-Type"="application/json"
    # }

# $response4 = Invoke-WebRequest -Method POST -Headers $headers https://sand007.insights.health.ge.com:8945/api/v1/dashboards/5a69082ef1095d4419000013/publish?force=true