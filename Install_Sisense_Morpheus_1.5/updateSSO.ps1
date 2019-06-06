$access_token=$args[0]
$website_port=$args[1]
$ssoFile=$args[2]

$headers = @{
	"Authorization" = "Bearer $access_token"
    "Accept" = "application/json"
    "Content-Type"="application/json"
    }
	
$body = Get-Content -Path $ssoFile -Raw

$response = Invoke-WebRequest -Method POST -Headers $headers -Body $body -Uri http://localhost:$website_port/api/v1/settings/sso