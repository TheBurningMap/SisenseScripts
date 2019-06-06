$access_token=$args[0]
$website_port=$args[1]
$dashFilePath=$args[2]

$headers = @{
	"Authorization" = "Bearer $access_token"
    "Accept" = "application/json"
    "Content-Type"="application/json"
    }
	
$body = Get-Content -Path $dashFilePath -Raw

$response = Invoke-WebRequest -Method POST -Headers $headers -Body $body -Uri http://localhost:$website_port/api/dashboards/import

$responseContent = echo $response.Content | ConvertFrom-Json

$shareId = echo $responseContent.oid

echo $shareId