$username=$args[0]
$password=$args[1]
$website_port=$args[2]


$headers = @{
    "Accept" = "application/json"
    "Content-Type"="application/x-www-form-urlencoded"
    }
	
$body = @{
	"username" = $username
	"password" = $password
	}

$response = Invoke-WebRequest -Method POST -Headers $headers -Body $body -Uri http://localhost:$website_port/api/v1/authentication/login

$responseContent = echo $response.Content | ConvertFrom-Json

$access_token = echo $responseContent.access_token

echo $access_token