$destDir=$args[0]
$workspace = Get-Location
$xmlLogfile = "$workspace\xmlLogs.log"
$cubeLogfile = "$workspace\cubeLogs.log"

if ($NULL -eq $destDir)
{
  echo "destDir is empty setting to default"
  $destDir='C:\Temp\ec'
  echo "destDir: $destDir"
}

foreach($ec in Get-Content .\ElastiCubePathListBackup.txt) {
	echo "$ec"
	
$dirName = Split-Path "$ec" -leaf

echo $dirName

if ((test-path $ec\ElastiCube.xml))
{
$command = 'C:\"Program Files"\Sisense\Prism\psm.exe ecube convert name="$ec\ElastiCube.xml"'
iex $command
}
Else
{
echo "$ec xml file doesn't exist" | Add-content $xmlLogfile
}

if ((test-path $ec\ElastiCube.ecube))
{
Copy-Item "$ec\ElastiCube.ecube" -Destination "$destDir\$dirName.ecube" 
}
Else
{
echo "$ec cube file doesn't exist" | Add-content $cubeLogfile
}

}