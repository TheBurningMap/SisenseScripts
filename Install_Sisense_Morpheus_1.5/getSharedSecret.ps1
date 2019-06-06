$access_token=$args[0]
$website_port=$args[1]

$authHeader = @{
	"Authorization" = "Bearer $access_token"
	}

$responseSSO = Invoke-WebRequest -Method GET -Headers $authHeader -Uri http://localhost:$website_port/api/v1/settings/sso
$responseSSOContent = echo $responseSSO.Content | ConvertFrom-Json
$sharedSecret = echo $responseSSOContent.sharedSecret

echo $sharedSecret