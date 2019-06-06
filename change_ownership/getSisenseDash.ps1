$file_content = Get-Content "dashboards.conf"
$file_content = $file_content -join [Environment]::NewLine
$configuration = ConvertFrom-StringData($file_content)
$gitrepo = $configuration.'gitrepo'
$gitbranch = $configuration.'gitbranch'
$hostName = $configuration.'hostName'
$gitfolder = $configuration.'gitfolder'

$baseURL=""
$access_token=""
$headers=""
. .\hosts.ps1 $hostName
$workspace = Get-Location
cd $workspace
If((test-path $workspace\Sisense_Dashboards))
{
      Remove-Item -recurse -force -confirm:$false Sisense_Dashboards
}
git clone $gitrepo Sisense_Dashboards -q
cd Sisense_Dashboards
If(( $gitbranch -ne "master" ))
{
git checkout -t -b $gitbranch origin/$gitbranch -q
}
$hostDir = "$workspace\Sisense_Dashboards\$gitfolder"
If(!(test-path $hostDir))
{
      New-Item -ItemType Directory -Force -Path $hostDir
}
cd $hostDir
# Get all the Dashboard OIDs
$headers = @{
    "Accept" = "application/json"
	"Authorization" = "Bearer $access_token"
	}
	
$responseOIDs = Invoke-WebRequest -Method GET -Headers $headers -Uri $baseURL/api/v1/dashboards
# $ErrorActionPreference = "Stop"
$responseContent = echo $responseOIDs.Content | ConvertFrom-Json
# $ErrorActionPreference = "Stop"
$OIDs = echo $responseContent.oid
echo $OIDs | Out-File -FilePath OIDs.txt -Force
Get-Content OIDs.txt | foreach {
    echo "processing DashboardID : $_"
	$headers = @{
		"Authorization" = "Bearer $access_token"
		"Accept" = "application/json"
		}
		
	$responsereq = Invoke-WebRequest -Method GET -Headers $headers -Body $body -Uri $baseURL/api/v1/dashboards/$_
    $responseparentFolder = echo $responsereq.Content | ConvertFrom-Json
    $parentFolderID = $responseparentFolder.parentFolder
	$responseTitle = $responseparentFolder.title.replace('\','_').replace('/','_').replace(':','_').replace('*','_').replace('?','_').replace('<','_').replace('>','_').replace('|','_').replace('"','_')
	If($parentFolderID)
	{
		$responseid = Invoke-WebRequest -Method GET -Headers $headers -Uri $baseURL/api/v1/folders/$parentFolderID
        $res = echo $responseid.Content | ConvertFrom-Json
        $parent_folder = $res.name.replace('\','_').replace('/','_').replace(':','_').replace('*','_').replace('?','_').replace('<','_').replace('>','_').replace('|','_').replace('"','_')
		$responsereq1 = Invoke-WebRequest -Method GET -Headers $headers -Body $body -Uri $baseURL/api/v1/folders/$parentFolderID/ancestors
        $responseFolder = echo $responsereq1.Content | ConvertFrom-Json
        $f_name =  $responseFolder.name.replace('\','_').replace('/','_').replace(':','_').replace('*','_').replace('?','_').replace('<','_').replace('>','_').replace('|','_').replace('"','_')
		[array]::Reverse($f_name)
        $concat = $f_name | ForEach { $_.replace('rootFolder','') } | where {$_ -ne ""} 
        $joinLine = echo $concat $parent_folder
		$result = $joinLine -join "\"
		$CompleteFolderPath = $hostDir,$result -join "\"
		If((test-path $workspace\Sisense_Dashboards))
		{
			$createFolder = New-Item $CompleteFolderPath -ItemType Directory -Force
		}
		cd $CompleteFolderPath
	}
	$responseDASH = Invoke-RestMethod -Headers $headers -Uri $baseURL/api/v1/dashboards/$_/export/dash
	$responseTitle2 = $responseDASH.title
	if (!($responseTitle2))
	{
		$responseDASH | Set-Content "$responseTitle.dash"
	}
	Else
	{
		$responseDASH | ConvertTo-Json -Depth 50 | Set-Content "$responseTitle.dash"
	}
	echo "dash file : $responseTitle.dash"
	cd $hostDir
	$CompleteFolderPath  = ""
	$responseTitle = ""
	$parentFolderID = ""
	$responseTitle2 = ""
	$responseDASH= ""
}
rm -force OIDs.txt
git pull
git add .
git commit -a -m "Updated dashboards for $hostName" -q
git push -q
cd $workspace
If((test-path $workspace\Sisense_Dashboards))
{
      Remove-Item -recurse -force -confirm:$false $workspace\Sisense_Dashboards
}