$file_content = Get-Content "dashboards.conf"
$file_content = $file_content -join [Environment]::NewLine
$configuration = ConvertFrom-StringData($file_content)
$hostName = $configuration.'hostName'
. .\hosts.ps1 $hostName


# $headers = @{
    # "Accept" = "application/json"
    # "Content-Type"="application/x-www-form-urlencoded"
    # }
	
# $body = @{
	# "username" = "morphues.internal.beta002@ge.com"
	# "password" = "M0rpheusBeta002@321"
	# }

# $baseURL = "https://beta002.insights.health.ge.com:8945";

# $response = Invoke-WebRequest -Method POST -Headers $headers -Body $body -Uri $baseURL/api/v1/authentication/login

# $responseContent = echo $response.Content | ConvertFrom-Json

# $access_token = echo $responseContent.access_token

# echo $access_token

$headers = @{
    "Accept" = "application/json"
	"Authorization" = "Bearer $access_token"
	}
	
$response1 = Invoke-WebRequest -Method GET -Headers $headers -Uri $baseURL/api/elasticubes/metadata

$res1 = echo $response1.Content | ConvertFrom-Json

$titles = $res1.title

echo $titles | Set-Content ecdatalist.txt
