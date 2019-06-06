$file_content = Get-Content "dashboards.conf"
$file_content = $file_content -join [Environment]::NewLine
$configuration = ConvertFrom-StringData($file_content)
$hostName = $configuration.'hostName'

# $status=""
$cubeName=""
# $type=""
$baseURL=""
$access_token=""
$headers=""
. .\hosts.ps1 $hostName
$cubeName = Read-Host -Prompt "`nCube Name"
# $type1 = Read-Host -Prompt "`nEntire or Schema Changes"

$headers = @{
						  "Authorization" = "Bearer $access_token"
						  "Accept" = "application/json"
						  "Content-Type"="application/json"
						}
						
$status = Invoke-WebRequest -Method POST -Headers $headers -Uri $baseURL/api/elasticubes/localhost/$cubeName/startBuild?type=Entire

# $statuscode = $status.StatusCode

# echo "status is $statuscode"

# if (($statuscode == 200))
# {
# echo "Cube started buidling"
# } 