$ipV4 = Test-Connection -ComputerName (hostname) -Count 1  | Select -ExpandProperty IPV4Address
$IPAddress = $ipv4.IPAddressToString
$x = nslookup $IPAddress | sls Name:
$result = $x.tostring().trim()
$hostname = $result.TrimStart("Name:").Trim(" `t")
echo $hostname