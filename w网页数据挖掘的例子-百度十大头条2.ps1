# w��ҳ�����ھ�����ӣ��ٶ�
$ie = new-object -com "InternetExplorer.Application"
$ie.navigate("http://top.baidu.com")
[System.Threading.Thread]::Sleep(6000)
$doc = $ie.document
$table = $doc.getElementById("hot-list")
$��� = $table.innertext
Write-Host "-----------��ǰʮ��ͷ����--------------"
Write-Host $���
$ie.quit()



