#	保存磁盘信息
$global:strInfo=""
#	获取本机计算机名称
$systemName=(New-Object -ComObject WScript.network).computername
$domainInfo=(New-Object -ComObject Wscript.network).userdomain
$computername=$systemName+"."+$domainInfo+".com"
#	获取磁盘信息
function GetDiskInfo()
{
$diskObj=Get-WmiObject -Class Win32_Volume -Filter "Drivetype='3'"
foreach ($disk in $diskObj)
{
	$drive=$disk.DriveLetter
	[int]$free=$disk.FreeSpace/1GB
	[int]$capacity=$disk.Capacity/1GB
	$usedSpace="{0:n2}" -f ((($capacity-$free)/$capacity)*100)
	$global:strInfo +=("磁盘 $drive 的剩余空间还剩 $free GB.使用率 $usedSpace % "+"`n")
}
}

function SendMail()
{
#	配置发送服务器
	$smtpServer="邮件服务器"
	$smtpUser="发送用户"
	$smtpPassword="用户密码"
#	创建邮件对象
	$mail=New-Object system.Net.Mail.MailMessage
	#	设置地址
	# 	发送和接受可以为同一用户
	$mailAddress="发送用户"
	$mailToAddress="接收用户"
	$mail.From=New-Object system.Net.Mail.MailAddress($mailAddress)
	$mail.To.Add($mailToAddress)
#	配置连接
	$mail.subject=$computername+"磁盘空间!"
	$mail.Priority="High"
	$mail.body=$mail.subject+"`n"+ $global:strInfo
#	发送邮件
	$smtp=New-Object system.Net.Mail.SmtpClient -ArgumentList $smtpServer
	$smtp.Credentials=New-Object system.Net.NetworkCredential -ArgumentList $smtpUser,$smtpPassword
	$smtp.send($mail)
}

GetDiskInfo
sleep 2
SendMail
# Write-Host "ok"
exit

