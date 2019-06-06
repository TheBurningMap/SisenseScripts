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
$headers = @{
    "Accept" = "application/json"
	"Authorization" = "Bearer $access_token"
	}
	
$workspace = Get-Location

cd $workspace
If((test-path $workspace\Sisense_Dashboards))
{
      Remove-Item -recurse -force -confirm:$false $workspace\Sisense_Dashboards
}

git clone $gitrepo Sisense_Dashboards -q
cd Sisense_Dashboards
If(( $gitbranch -ne "master" ))
{
git checkout -t -b $gitbranch origin/$gitbranch -q
}
$dashFiles = Get-ChildItem -Path $gitfolder -Filter '*.dash' -Recurse -ErrorAction SilentlyContinue -Force | %{$_.FullName}
$i=0
foreach($dashFile in $dashFiles)
{
 
	$dashData = get-content $dashFile | ConvertFrom-Json
	$dashOID = echo $dashData.oid
	$dashTitle = echo $dashData.title
	$oIDtITLE = $dashData | Select-Object oid,title
	echo $oIDtITLE
	}
	
	
	
	
	
	
	
	
	
	
	
	# $responsereq = Invoke-WebRequest -Method GET -Headers $headers -Uri $baseURL/api/v1/dashboards/$dashOID/exists
	# $check = $responsereq | ConvertFrom-Json
	# $dashboard = $check.exists
	# if ($dashboard -ne "True")
	# {
		# echo "$dashFile , Dashboard doesn't exists"
		# $i++
		# $userResponse = Read-Host -Prompt "`nDo you want to delete from git repo (yes/no)"
        # while($userResponse -ne "yes")
        # {
           # if ($userResponse -eq "no")
            # {
		      # break
            # }
        # $userResponse = Read-Host -Prompt "`nPlease provide correct input, Do you want to delete from git repo (yes/no)"
           # if ($userResponse -eq "no")
           # {
				# break
           # }
        # }
        # if($userResponse -eq "yes")
		# {
			# git pull
			# git rm $dashFile --quiet
			# git commit -a -m "deleting from $hostName" -q
			# git push -q
			# echo "Dasboards that doesn't exist on sisense got deleted from GIT"
		# }
	# }
# }
# if ($i -eq "0")
# {
	# echo "All Dashboards on GIT are in sync with sisense"
# }
# cd $workspace
# If((test-path $workspace\Sisense_Dashboards))
# {
	# Remove-Item -recurse -force -confirm:$false $workspace\Sisense_Dashboards
# }
