$access_token=$args[0]
$website_port=$args[1]

$headers = @{
    "Authorization" = "Bearer $access_token"
    "Accept" = "application/json"
    }
	
$response1 = Invoke-WebRequest -Method GET -Headers $headers -Body $body -Uri http://localhost:$website_port/api/v1/groups?name=everyone

$responseUserContent =  echo $response1.Content | ConvertFrom-Json

$group_Id = echo $responseUserContent._id

echo $group_Id