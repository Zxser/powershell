
@echo 管理员权限运行
@echo 如果使用powershell remoting远程。本机，远程机，都要用管理员权限运行一遍。
"C:\WINDOWS\system32\windowspowershell\v1.0\powershell.exe" -command "Set-ExecutionPolicy -ExecutionPolicy Unrestricted"
"C:\WINDOWS\syswow64\windowspowershell\v1.0\powershell.exe" -command "Set-ExecutionPolicy -ExecutionPolicy Unrestricted"
pause





