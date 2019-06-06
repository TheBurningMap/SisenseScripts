$baseURL = "https://demo001.insights.health.ge.com:8945"
$headers = @{
    "Accept" = "application/json"
	"Authorization" = "Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJ1c2VyIjoiNTg4NmFhZjIzOWRmNzFiNDUyN2JmMDI5IiwiYXBpU2VjcmV0IjoiNDQyOGQyOWMtNTI0Ny1iYjFkLTJlYjctOGIwMWNjZjU5Nzg2IiwiaWF0IjoxNTE5OTIxMzA1fQ.oSg53mh38vsVJnEUsnsxSOAKkJ1E3z9EcJEsStVPRpg"
	}

$fResponse = Invoke-WebRequest -Method GET -Headers $headers -Uri $baseURL/api/v1/folders
$fContent = echo $fResponse.Content | Convertfrom-Json
$fList = $fContent | select-object oid,name | where {$_.name -ne "rootFolder"}
$fList


# $fid = Read-Host -Prompt "`nEnter the folder id as an input"
$fid = "5ad7d523588b94d4b5000019"

$stResponse = Invoke-WebRequest -Method GET -Headers $headers -Uri $baseURL/api/v1/folders/$fid/subtree
$stContent = echo $stResponse.Content | Convertfrom-Json
$stOID = echo $stContent.oid
$stName = echo $stContent.name
foreach($OID in $stOID)
{
	echo "processing $OID"
	$dashOID = Invoke-WebRequest -Method GET -Headers $headers -Uri $baseURL/api/v1/folders/$OID'?expand=dashboards(oid)'
	$dContent = echo $dashOID.Content | Convertfrom-Json
	$dOID = $dContent.dashboards.oid
	$dOID
}


