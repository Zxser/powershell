# w网页数据挖掘的例子，百度
$ie = new-object -com "InternetExplorer.Application"
$ie.navigate("http://top.baidu.com")
[System.Threading.Thread]::Sleep(6000)
$doc = $ie.document
$table = $doc.getElementById("hot-list")
$结果 = $table.innertext
Write-Host "-----------当前十大头条：--------------"
Write-Host $结果
$ie.quit()



