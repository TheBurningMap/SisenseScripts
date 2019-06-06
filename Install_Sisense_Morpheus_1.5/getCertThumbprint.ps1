$cert = Get-ChildItem -path cert:\LocalMachine\my | Where-Object {$_.subject -like "*.insights.health.ge.com*"}
$certthumb = $cert | select Thumbprint | ft -HideTableHeaders | Out-String
$cert_thumbprint = $certthumb.trim()
echo $cert_thumbprint.ToLower()