$OIDInput=$args[0]
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
$hostDir = "$workspace\$gitfolder"

If(!(test-path $hostDir))
{
      New-Item -ItemType Directory -Force -Path $hostDir | Out-Null
}
cd $hostDir
	echo "exporting $OIDInput dashboard..."
	$headers = @{
		"Authorization" = "Bearer $access_token"
		"Accept" = "application/json"
		}
	$responsereq = Invoke-WebRequest -Method GET -Headers $headers -Body $body -Uri $baseURL/api/v1/dashboards/$OIDInput
	$responseparentFolder = echo $responsereq.Content | ConvertFrom-Json
	$parentFolderID = $responseparentFolder.parentFolder
	$responseTitle = $responseparentFolder.title.replace('\','_').replace('/','_').replace('/','_').replace(':','_').replace('*','_').replace('?','_').replace('<','_').replace('>','_').replace('|','_').replace('"','_')
	If($parentFolderID)
		{
			$responseid = Invoke-WebRequest -Method GET -Headers $headers -Uri $baseURL/api/v1/folders/$parentFolderID
			$res = echo $responseid.Content | ConvertFrom-Json
			$parent_folder = $res.name
			$responsereq1 = Invoke-WebRequest -Method GET -Headers $headers -Body $body -Uri $baseURL/api/v1/folders/$parentFolderID/ancestors
			$responseFolder = echo $responsereq1.Content | ConvertFrom-Json
			$f_name =  $responseFolder.name
			[array]::Reverse($f_name)
			$concat = $f_name | ForEach { $_.replace('rootFolder','') } | where {$_ -ne ""}
			$joinLine = echo $concat $parent_folder
			$result = $joinLine -join "\"
			$CompleteFolderPath = $hostDir,$result -join "\"
			If(!(test-path $CompleteFolderPath))
			{
				$createFolder = New-Item $CompleteFolderPath -ItemType Directory -Force 
			}
			cd $CompleteFolderPath
		}
	$responseDASH = Invoke-RestMethod -Headers $headers -Uri $baseURL/api/v1/dashboards/$OIDInput/export/dash
	$responseTitle2 = $responseDASH.title
	if (!($responseTitle2))
	{
		$responseDASH | Set-Content "$responseTitle.dash"
	}
	Else
	{
			$responseDASH | ConvertTo-Json -Depth 20 | Set-Content "$responseTitle.dash"
	}
	echo "dash file : $responseTitle.dash"
	cd $hostDir
	$CompleteFolderPath  = ""
	$responseTitle = ""
	$parentFolderID = ""
	cd $workspace
	git clone $gitrepo Sisense_Dashboards -q
	cd Sisense_Dashboards
	git checkout -t -b $gitbranch origin/$gitbranch -q
	Copy-Item "$hostDir" -Destination "$workspace\Sisense_Dashboards" -Recurse -Force
	git pull
	git add .
	git commit -a -m "Updated dashboards for $hostName" -q
	git push -q
	echo "`nExported dashboard(s) are pushed to $gitrepo repository under $gitfolder directory`n"