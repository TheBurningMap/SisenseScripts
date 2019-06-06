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

If((test-path $workspace\data))
{
	Remove-Item -recurse -force -confirm:$false $workspace\data
}
If((test-path $workspace\splits))
{
	Remove-Item -recurse -force -confirm:$false $workspace\splits
}
If((test-path $workspace\OIDs.txt))
{
	Remove-Item -recurse -force -confirm:$false $workspace\OIDs.txt
}
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

# Get all the Dashboard OIDs
$headers = @{
    "Accept" = "application/json"
	"Authorization" = "Bearer $access_token"
	}
	
echo "Preparing Dashboard OIDs list"
$responseOIDs = Invoke-WebRequest -Method GET -Headers $headers -Uri $baseURL/api/v1/dashboards
$ErrorActionPreference = "Stop"
$responseContent = echo $responseOIDs.Content | ConvertFrom-Json
$OIDs = echo $responseContent.oid
echo $OIDs | Out-File -FilePath $workspace\OIDs.txt -Force
echo "Dashboard OIDs list is ready for processing"
cd $workspace

If(!(test-path splits))
{
    New-Item -ItemType Directory -Force -Path splits | out-null
}
If(!(test-path data))
{
    New-Item -ItemType Directory -Force -Path data | out-null
}

$j=0; Get-Content $workspace\OIDs.txt -ReadCount 10 | %{
                                                        $j++;
														$_ | Out-File splits\out_$j.txt;
													}
$k=1
get-job | remove-job
# $MaxThreads = 20
foreach($file in (Get-ChildItem splits -Name -File))
{
   Start-Job -Name AIJob$k -FilePath "prepareDashList.ps1" -ArgumentList $file,$k,$baseURL,$access_token,$workspace | out-null
   $k++
}
While (Get-Job -State "Running")
{
	sleep 2
}
echo "Dashboards List:"
Get-ChildItem data -Name -File | Get-Content | Sort-Object | Format-Table
DO
{
	cd $hostDir
	$OIDInput = Read-Host -Prompt "`nInput Dashboard_ID to export dashboard"
	echo "exporting $OIDInput dashboard..."
	$headers = @{
		"Authorization" = "Bearer $access_token"
		"Accept" = "application/json"
		}
	$responsereq = Invoke-WebRequest -Method GET -Headers $headers -Uri $baseURL/api/v1/dashboards/$OIDInput
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
			#$arr = $arr[1..($arr.Length-1)]
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
	$userResponse = Read-Host -Prompt "`nDo you want to continue exporting dashbards (yes/no)"
	while($userResponse -ne "yes")
     {
	   if ($userResponse -eq "no")
	   {
			break
	   }
       $userResponse = Read-Host -Prompt "`nPlease provide correct input, Do you want to continue (yes/no)"
	   if ($userResponse -eq "no")
	   {
			break
	   }
     }

} While ($userResponse -eq "yes")

$gitResponse = Read-Host -Prompt "`nDo you want to push exported dashboards to git (yes/no)"
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
}

cd $workspace
If((test-path $workspace\OIDs.txt))
{
	Remove-Item -recurse -force -confirm:$false $workspace\OIDs.txt
}
If((test-path $workspace\$gitfolder))
{
	Remove-Item -recurse -force -confirm:$false $workspace\$gitfolder
}
# If((test-path $workspace\$hostDir))
# {
	# Remove-Item -recurse -force -confirm:$false $workspace\$hostDir
# }
If((test-path $workspace\Sisense_Dashboards))
{
	Remove-Item -recurse -force -confirm:$false $workspace\Sisense_Dashboards
}
If((test-path $workspace\data))
{
	Remove-Item -recurse -force -confirm:$false $workspace\data
}
If((test-path $workspace\splits))
{
	Remove-Item -recurse -force -confirm:$false $workspace\splits
}