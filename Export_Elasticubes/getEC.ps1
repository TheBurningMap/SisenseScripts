$host_name=$args[0]
$destDir=$args[1]

if ($NULL -eq $destDir)
{
  echo "destDir is empty setting to default"
  # Set-Variable -Name "destDir" -Value C:\Temp
  $destDir='C:\Temp\ec'
  echo "destDir: $destDir"
}

foreach($ec in Get-Content .\exportMultiECList.txt) {
	echo "Processing $ec"
$command = 'C:\"Program Files"\Sisense\Prism\psm.exe ecube export name=$ec path=$destDir\$ec.ecdata serverAddress=$host_name force=True'
iex $command
}