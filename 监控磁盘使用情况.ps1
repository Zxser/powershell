#监控磁盘空间
function funLine($strIN)
{
	#蛋疼的用“=”来分行
	$num = $strIN.length
	for ($i = 1; $i -le $num; $i++)
	{
		$funLine=$funLine+"="
	}
	Write-Host -ForegroundColor Yellow $strIN
	Write-Host -ForegroundColor darkYellow $funLine
}
#需要获取磁盘信息的计算机集合
$aryComputer = "localhost", "loopback"
foreach ($computer in $aryComputer)
{
	#获得计算机上的分区信息 "drivetype=3"限定为本地磁盘
	$volumeSet = Get-WmiObject -Class Win32_Volume -ComputerName $computer `
	-Filter "drivetype=3"
	#轮训计算机上的分区		  
	foreach ($volume in $volumeSet)
	{
		#获得盘符
		$drive = $volume.driveLetter
		#剩余空间
		[int]$free = $volume.freespace / 1GB
		#总空间
		[int]$capacity = $volume.capacity / 1GB
		funLine("Drivers on $computer computer:")
		Write-Host "Analyzing drive $drive $($volume.label) on $($volume.__server)"
		"`t`t Percent free space on drive $drive " + "{0:N2}" -f (($free/$capacity)*100)
		
	}
	
}