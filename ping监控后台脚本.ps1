#ping测试后台程序
#1.0 实现ping统计，错误日志功能 2012-11-13
$SqlConnection = New-Object System.Data.SqlClient.SqlConnection
$CnnString ="Server = 192.168.2.222; Database = pingstat;User Id = sa; Password = maikafei"
$SqlConnection.ConnectionString = $CnnString
$CC = $SqlConnection.CreateCommand();
$cc.CommandText="select * from host"
$dt1=New-Object System.Data.DataTable
$dt2=New-Object System.Data.DataTable
$da=New-Object System.Data.SqlClient.SqlDataAdapter($cc)
$null=$da.Fill($dt1) 
$cc.CommandText="select top 1 * from pingstat"
$da=New-Object System.Data.SqlClient.SqlDataAdapter($cc)
$null=New-Object System.Data.SqlClient.SqlCommandBuilder($da)
$null=$da.Fill($dt2) #表不能为空


$getping={param($saddr,$daddr)
$time=(get-date)
$ping = New-Object System.Net.NetworkInformation.Ping
$ping.send($daddr,4000)|select @{N="SAddr";E={$saddr}},@{N="DAddr";E={$_.Address}},@{N="DName";E={$daddr}},Status,RoundtripTime,@{N="Ptime";E={$time}}
}

$results=New-Object system.collections.arraylist
$rsp=[System.Management.Automation.Runspaces.RunspaceFactory]::CreateRunspacePool()
[void]$rsp.SetMaxRunspaces(2000)
[void]$rsp.SetMinRunspaces(300)
$rsp.Open()

$netid=gwmi Win32_NetworkAdapter |?{$_.NetConnectionStatus}| Select-Object DeviceID 
$hostname=ForEach ($id in $netid ){gwmi Win32_NetworkAdapterConfiguration|? {$_.index -eq $id.DeviceID -and $_.DefaultIPGateway -ne $null}}
$ipadd=$hostname.IPAddress[0].tostring()

$serlist=$dt1|?{$_.ipaddr -ne $ipadd -and  $_.flag}
$pcount=300
$t=(get-date)
Start-Sleep -s (299-(($t.Minute*60+$t.Second)%300))
for($i=0;$i -lt $pcount;$i++){
    sleep -m (1000-(get-date).Millisecond)
    foreach($server in $serlist){
        $gpc=[powershell]::Create()
        $gpc.RunspacePool=$rsp
        [void]$gpc.AddScript($getping)
        [void]$gpc.AddParameter("saddr",$ipadd)
        [void]$gpc.AddParameter("daddr",$server.ipaddr)
        $AsyncResult=$gpc.BeginInvoke()
        $result=New-Object psobject|select output,result,thread
        $result.output=$null
        $result.result=$AsyncResult
        $result.thread=$gpc
        [void]$results.add($result)
         }
         $i
}
$ptime=(get-date)
do{
sleep 3
$t=$Results|%{$_.result}|?{!($_.IsCompleted)}
Write-Host "总进程数$($Results.count) 完成数$($Results.count-$t.length) 未完成数$($t.length)……"
}while($t)

foreach($thread in $Results){
$thread.output=$thread.thread.EndInvoke($thread.result)
}
$rsp.Close()
$pingstat=$Results|%{$_.output}|sort dname,Ptime

$dnames=$pingstat|group dname|select name
foreach($dname in $dnames){
$ping=$pingstat|?{$_.DName -eq $dname.name -and $_.Status -eq "Success"}|Measure  -property RoundtripTime -max -min -average
$newrow=$dt2.newrow()
$newrow["sid"]=($dt1|?{$_.ipaddr -eq $ipadd}).id
$newrow["did"]=($dt1|?{$_.ipaddr -eq $dname.name}).id
$newrow["pmin"]=$ping.Minimum
$newrow["pavg"]=[int]$ping.Average
$newrow["pmax"]=$ping.Maximum
$newrow["loss"]=$pcount-$ping.Count
$newrow["ptime"]=$ptime
$dt2.rows.add($newrow)
}
[void]$da.Update($dt2)

foreach($ping in $pingstat){
    if($ping.Status -ne "Success"){
    $sid=($dt1|?{$_.ipaddr -eq $ping.SAddr}).id
    $did=($dt1|?{$_.ipaddr -eq $ping.DName}).id
    $status=$ping.Status
    $ptime=$ping.Ptime
    $lasttime=$ping.Ptime.AddSeconds(-1)
    $cc.CommandText="UPDATE [pingstat].[dbo].[errorlog]
       SET [count] = count+1
          ,[ptime] ='$ptime'
     WHERE [sid]=$sid and [did]=$did and [status]='$status' and [ptime]='$lasttime'"
    if($SqlConnection.State -ne "Open"){$SqlConnection.Open()} 
        if(!$cc.ExecuteNonQuery()){
        $cc.CommandText="INSERT INTO [pingstat].[dbo].[errorlog]
                   ([sid],[did],[count],[status],[ptime])
             VALUES
                   ($sid,$did,1,'$status','$ptime')"
        $unll=$cc.ExecuteNonQuery()
        }
    }
}
exit


<#
USE [pingstat]
GO
/****** Object:  Table [dbo].[pingstat]    Script Date: 04/26/2013 17:46:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[pingstat](
	[sid] [int] NULL,
	[did] [int] NULL,
	[pavg] [int] NULL,
	[pmax] [int] NULL,
	[pmin] [int] NULL,
	[loss] [int] NULL,
	[ptime] [smalldatetime] NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[errorlog]    Script Date: 04/26/2013 17:46:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[errorlog](
	[sid] [int] NULL,
	[did] [int] NULL,
	[count] [int] NULL,
	[status] [nvarchar](32) NOT NULL,
	[ptime] [datetime] NOT NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[host]    Script Date: 04/26/2013 17:46:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[host](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[ipaddr] [nvarchar](50) NOT NULL,
	[idc] [nvarchar](50) NULL,
	[appname] [nvarchar](50) NULL,
	[flag] [tinyint] NULL,
	[memo] [nvarchar](50) NULL,
 CONSTRAINT [PK_host] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Default [DF_host_fig]    Script Date: 04/26/2013 17:46:03 ******/
ALTER TABLE [dbo].[host] ADD  CONSTRAINT [DF_host_fig]  DEFAULT ((1)) FOR [flag]
GO
#>