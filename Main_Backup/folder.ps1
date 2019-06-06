$confFile = "dashboards.conf"
$file_content = Get-Content $confFile
$file_content = $file_content -join [Environment]::NewLine
$configuration = ConvertFrom-StringData($file_content)
$gitrepo = $configuration.'gitrepo'
$gitbranch = $configuration.'gitbranch'
$hostName = $configuration.'hostName'
$gitfolder = $configuration.'gitfolder'
$folderid = $configuration.'folderid'
$baseURL=""
$access_token=""
$headers=""
. .\hosts.ps1 $hostName
$workspace = Get-Location
cd $workspace
If((test-path $workspace\Sisense_Dashboards))
{
      Remove-Item -recurse -force -confirm:$false $workspace\Sisense_Dashboards
}
If((test-path $workspace\$gitfolder))
{
	Remove-Item -recurse -force -confirm:$false $workspace\$gitfolder
}
If((test-path $workspace\OIDs.txt))
{
	Remove-Item -recurse -force -confirm:$false $workspace\OIDs.txt
}
If((test-path $workspace\OIDname.txt))
{
	Remove-Item -recurse -force -confirm:$false $workspace\OIDname.txt
}
$hostDir = "$workspace\$gitfolder"
If(!(test-path $hostDir))
{
      New-Item -ItemType Directory -Force -Path $hostDir | Out-Null
}

$headers = @{
    "Accept" = "application/json"
	"Authorization" = "Bearer $access_token"
	}
	
if ($folderid -eq "")
{
	$fResponse = Invoke-WebRequest -Method GET -Headers $headers -Uri $baseURL/api/v1/folders
	$fContent = echo $fResponse.Content | Convertfrom-Json
	$fList = $fContent | select-object oid,name | where {$_.name -ne "rootFolder"}
	$fList | Out-File -FilePath $workspace\OIDname.txt -Force
	Get-Content $workspace\OIDname.txt
	$fid = Read-Host -Prompt "`nEnter the folder id as an input"
	$userResponse = Read-Host -Prompt "`nDo you want to preserve folder id to reuse (yes/no)"
	while($userResponse -ne "yes")
{
   if ($userResponse -eq "no")
   {
		break
   }
   $userResponse = Read-Host -Prompt "`nPlease provide correct input, Do you want to reuse (yes/no)"
   if ($userResponse -eq "no")
   {
		break
   }
}
	if ( $userResponse -eq "yes" )
	{
		$confContent = Get-Content -Path $confFile
		$confContent | ForEach-Object {$_ -Replace "folderid=.*","folderid=$fid"} | Set-Content $confFile
	}
}
else
{
	$fid = $folderid
}

$stResponse = Invoke-WebRequest -Method GET -Headers $headers -Uri $baseURL/api/v1/folders/$fid/subtree
$stContent = echo $stResponse.Content | Convertfrom-Json
$stOID = echo $stContent.oid
$stName = echo $stContent.name
$parentFolderID = ""
$parent_folder = ""
$basePath = ""
$responsereq1 = ""
$parentFolderID = ""
$parentFolderID = $fid
$fResponse = Invoke-WebRequest -Method GET -Headers $headers -Uri $baseURL/api/v1/folders
$fContent = echo $fResponse.Content | Convertfrom-Json
$fDesc = $fContent | select-object oid,name | where {$_.oid -eq $parentFolderID}
$parent_folder = $fDesc.name
# $parent_folder
# echo "parentFolderID: $parentFolderID"

$responsereq1 = Invoke-WebRequest -Method GET -Headers $headers -Body $body -Uri $baseURL/api/v1/folders/$parentFolderID/ancestors
$responseFolder = echo $responsereq1.Content | ConvertFrom-Json
$f_name =  $responseFolder.name
[array]::Reverse($f_name)
$concat = $f_name | ForEach { $_.replace('rootFolder','') } | where {$_ -ne ""}
if($concat -eq "")
{
	# $joinLine = $parent_folder
	$result = $parent_folder
}
else
{
	$joinLine = echo $concat $parent_folder
	$result = $joinLine -join "\"
}

$CompleteFolderPath = $hostDir,$result -join "\"
$basePath = $CompleteFolderPath
$parentFolderID = ""
$parent_folder = ""
$CompleteFolderPath = ""
# echo "basePath : $basePath"

###
foreach($OID in $stOID)
{
	echo "processing $OID"
	try {
	$dashOID = Invoke-WebRequest -Method GET -Headers $headers -Uri $baseURL/api/v1/folders/$OID'?expand=dashboards(oid)'
	} catch { "WARN: OID Doesn't exist" }
	$dContent = echo $dashOID.Content | Convertfrom-Json
	$dOID = $dContent.dashboards.oid | Out-File -FilePath $workspace\OIDs.txt -Force -append 
	echo $dOID 
}
Get-Content OIDs.txt | foreach {
echo "processing DashboardID : $_"
    $responsereq = Invoke-WebRequest -Method GET -Headers $headers -Body $body -Uri $baseURL/api/v1/dashboards/$_
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
		# If((test-path $workspace\Sisense_Dashboards))
		If((test-path $workspace))
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
		$responseDASH | ConvertTo-Json -Depth 25 | Set-Content "$responseTitle.dash"
	}
	echo "dash file : $responseTitle.dash"
	cd $hostDir
	$CompleteFolderPath  = ""
	$responseTitle = ""
	$parentFolderID = ""
	$responseTitle2 = ""
	$responseDASH= ""
}
# function foo {
function integrate {
    cd $workspace
	git clone $gitrepo Sisense_Dashboards -q
	cd Sisense_Dashboards
	git checkout -t -b $gitbranch origin/$gitbranch -q
	If(!(test-path $workspace\Sisense_Dashboards\$gitfolder))
	{
      New-Item -ItemType Directory -Force -Path $workspace\Sisense_Dashboards\$gitfolder | Out-Null
	}
	#Copy-Item "$hostDir" -Destination "$workspace\Sisense_Dashboards" -Recurse -Force
	# cd $basePath
	# Copy-Item * -Destination "$workspace\Sisense_Dashboards\$gitfolder" -Recurse -Force
	# Copy-Item "$basePath" -Destination "$workspace\Sisense_Dashboards\$gitfolder" -Recurse -Force
	Copy-Item "$basePath\*" -Destination "$workspace\Sisense_Dashboards\$gitfolder" -Recurse -Force
	git pull
	git add .
	git commit -a -m "Updated dashboards for $hostName" -q
	git push -q
	echo "`nExported dashboard(s) are pushed to $gitrepo repository under $gitfolder directory`n"
}
if (!($folderid))
{
$gitResponse = Read-Host -Prompt "`nDo you want to integrate dashboards to git (yes/no)"
while($gitResponse -ne "yes")
{
   if ($gitResponse -eq "no")
   {
		break
   }
   $gitResponse = Read-Host -Prompt "`nPlease provide correct input, Do you want to continue (yes/no)"
   if ($gitResponse -eq "no")
   {
		break
   }
}
   if ( $gitResponse -eq "yes" )
  { 
    # foo
    integrate
  }
}
Else
{
    # foo
    integrate
}
cd $workspace
If((test-path $workspace\OIDs.txt))
{
	Remove-Item -recurse -force -confirm:$false $workspace\OIDs.txt
}
If((test-path $workspace\OIDname.txt))
{
	Remove-Item -recurse -force -confirm:$false $workspace\OIDname.txt
}
If((test-path $workspace\Sisense_Dashboards))
{
	Remove-Item -recurse -force -confirm:$false $workspace\Sisense_Dashboards
}
If((test-path $workspace\$gitfolder))
{
	Remove-Item -recurse -force -confirm:$false $workspace\$gitfolder
}