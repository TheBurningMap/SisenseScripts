$file=$args[0]
$find=$args[1]
$replace=$args[2]
(Get-Content $file).replace($find, $replace) | Set-Content $file