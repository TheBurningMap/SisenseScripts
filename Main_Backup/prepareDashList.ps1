$file=$args[0]
$counter=$args[1]
$baseURL=$args[2]
$access_token=$args[3]
$workspace=$args[4]
$outFile = "$workspace\data\dashList_$counter.txt"

New-Item $outFile -ItemType file
Get-Content $workspace\splits\$file | foreach {
    $headers = @{
		"Authorization" = "Bearer $access_token"
		"Accept" = "application/json"
		}
	$responsereq = Invoke-WebRequest -Method GET -Headers $headers -Uri $baseURL/api/v1/dashboards/$_
    $responseparentFolder = echo $responsereq.Content | ConvertFrom-Json
    $parentFolderID = $responseparentFolder.parentFolder
	$responseTitle = $responseparentFolder.title.replace('\','_').replace('/','_').replace('/','_').replace(':','_').replace('*','_').replace('?','_').replace('<','_').replace('>','_').replace('|','_').replace('"','_')
	If($parentFolderID)
	{
		$responseid = Invoke-WebRequest -Method GET -Headers $headers -Uri $baseURL/api/v1/folders/$parentFolderID
		$res = echo $responseid.Content | ConvertFrom-Json
		$parent_folder = $res.name
		$responsereq1 = Invoke-WebRequest -Method GET -Headers $headers -Uri $baseURL/api/v1/folders/$parentFolderID/ancestors
		$responseFolder = echo $responsereq1.Content | ConvertFrom-Json
		$f_name =  $responseFolder.name
		[array]::Reverse($f_name)
		$concat = $f_name | ForEach { $_.replace('rootFolder','') } | where {$_ -ne ""}
		If (!($concat))
		{
			$result = $parent_folder
		}
		Else
		{
			$joinLine = echo $concat $parent_folder
			$result = $joinLine -join "\"
		}
		echo "$result\$responseTitle.dash  , [$_]" | Out-File -FilePath $outFile -append
	}
	Else
	{
		echo "$responseTitle.dash  , [$_]" | Out-File -FilePath $outFile -append
	}
	$i++
}