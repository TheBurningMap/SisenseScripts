$file_content = Get-Content "dashboards.conf"
$file_content = $file_content -join [Environment]::NewLine
$configuration = ConvertFrom-StringData($file_content)
$hostName = $configuration.'hostName'

$cubeName=""
$type=""
$baseURL=""
$access_token=""
$headers=""
$headers1=""
. .\hosts.ps1 $hostName


$headers = @{
    "Accept" = "application/json"
	"Authorization" = "Bearer $access_token"
	}
	
$response1 = Invoke-WebRequest -Method GET -Headers $headers -Uri $baseURL/api/elasticubes/metadata
echo $response1

$res1 = echo $response1.Content | ConvertFrom-Json

$titles = $res1.title

# echo $titles | Set-Content ecdatalist.txt
echo $titles

$headers1 = @{
    "Accept" = "application/json"
	"Authorization" = "Bearer $access_token"
	}
	
$response2 = Invoke-WebRequest -Method GET -Headers $headers1 -Uri $baseURL/api/v1/dashboards/5b858546734ace8d74c3e218
# echo $response2

$res2 = echo $response2.Content | ConvertFrom-Json

$titles1 = $res2.datasource.title


echo $titles1
echo "##########################################################################################################"
$cubeName = Read-Host -Prompt "`nCube Name"
# $type = Read-Host -Prompt "`nCube Name"



try {
$headers = @{
						  "Authorization" = "Bearer $access_token"
						  "Accept" = "application/json"
						  "Content-Type"="application/json"
						}
			# $body = Get-Content "C:\dashboardscripts\linux\AdaaGH.ecdata" 
					# $owner_admin = Invoke-WebRequest -Method POST -Headers $headers -Body $body -Uri $baseURL/api/v2/elasticubes/import
					$a = Invoke-WebRequest -Method POST -Headers $headers -Uri $baseURL/api/elasticubes/localhost/$cubeName/startBuild?type=Entire
					
			} catch  { "WARN: failed to process or cube Not Found " }
			
			
			
# $headers = @{
    # "Accept" = "application/json"
	# "Authorization" = "Bearer $access_token"
	# }
	
# $response2 = Invoke-WebRequest -Method GET -Headers $headers -Uri $baseURL/api/elasticubes/servers/localhost/status


# $res1 = echo $response1.Content | ConvertFrom-Json

# $titles = $res1.title

# # echo $titles | Set-Content ecdatalist.txt
# echo $titles