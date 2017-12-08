# 会说话+弹窗口的hello world！

<#
第一步,把下面这几条语句存成文本文件，如 c:\hello.ps1
#>

<#
第二步,开启powershell脚本运行权限：
用管理员权限！！！打开一个cmd，输入：  
"C:\WINDOWS\system32\windowspowershell\v1.0\powershell.exe" -command "Set-ExecutionPolicy -ExecutionPolicy  RemoteSigned"
"C:\WINDOWS\syswow64\windowspowershell\v1.0\powershell.exe" -command "Set-ExecutionPolicy -ExecutionPolicy  RemoteSigned"
#>




<#
第三步，运行powershell，运行脚本，输入：
 "C:\WINDOWS\system32\windowspowershell\v1.0\powershell.exe"
在开启的powershell窗口中，输入    c:\hello.ps1
#>






echo "Hello world!"
$sapi = New-Object -COM Sapi.SpVoice
$sapi.Speak("Hello World!")
$sapi.Speak("你好!我是计算机合成语音，能说中文了！")
[reflection.assembly]::loadwithpartialname("System.Windows.Forms") | Out-Null
[System.Windows.Forms.MessageBox]::Show("Hello world!")


<#
调用脚本的方法，输入：
 "C:\WINDOWS\system32\windowspowershell\v1.0\powershell.exe"   -file      d:\xxxx.ps1
#>


<#
双击xxxx.ps1 自动运行脚本的方法，用管理员权限！！！打开一个cmd，输入：
assoc .ps1=Microsoft.PowerShellScript.1
ftype Microsoft.PowerShellScript.1="C:\WINDOWS\system32\windowspowershell\v1.0\powershell.exe" -command "& {%1}"
#>



