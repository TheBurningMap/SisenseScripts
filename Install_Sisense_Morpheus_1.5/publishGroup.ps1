$access_token=$args[0]
$website_port=$args[1]
$dashboardID=$args[2]
$sharesFile=$args[3]

# Share the dashboard with the 'everyone' group
$headers = @{
    "Authorization" = "Bearer $access_token"
    "Accept" = "application/json"
	"Content-Type"="application/json"
    }
	
$body = Get-Content -Path $sharesFile -Raw

$response3 = Invoke-WebRequest -Method PATCH -Headers $headers -Body $body -Uri http://localhost:$website_port/api/v1/dashboards/$dashboardID

#Publish dashboard for the 'everyone' group
$headers = @{
    "Authorization" = "Bearer $access_token"
    "Accept" = "application/json"
	"Content-Type"="application/json"
    }

$response4 = Invoke-WebRequest -Method POST -Headers $headers http://localhost:$website_port/api/v1/dashboards/$dashboardID/publish?force=true