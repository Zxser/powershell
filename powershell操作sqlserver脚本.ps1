#�������ݿ����
$SqlConnection =New-Object System.Data.SqlClient.SqlConnection
$SqlConnection.ConnectionString = "Data Source=IP;Network Library =DBMSSOCN ;Initial Catalog=dbname;user id=user;password=password;"

#�������ݿ�
$SqlConnection.Open()

$SqlCmd=New-Object  System.Data.SqlClient.SqlCommand
$SqlCmd.Connection=$SqlConnection

#ִ��һ��sql��䣬ѡ���Ҫ��������
$SqlCmd.CommandText="Select id,dmname,rdname,address  From dnsname  Where id  in(select prid from option where A = 0 and B = 0  and protype ='url' ) and isnull(isdel,'0')<>'1' and recordtype='url' " 
$SqlAdapter = New-Object System.Data.SqlClient.SqlDataAdapter
$SqlAdapter.SelectCommand = $SqlCmd

$DataSet = New-Object System.Data.DataSet

#��ѯ�õ�������
$count=$SqlAdapter.Fill($DataSet)

$DataSet.Tables[0] 

for ($i=0;$i -lt $count;$i++)
{
$id=$DataSet.Tables[0].rows[$i]["id"]
$dmname=$DataSet.Tables[0].rows[$i]["dmname"]
$rdname=$DataSet.Tables[0].rows[$i]["rdname"]
$address=$DataSet.Tables[0].rows[$i]["address"]

#��������һ��  ��echo д�뵽$filename�е��ַ���apache ��ʶ�����Ƹ����ˡ���˱���set-content ��add-content������Ϊ�������ַ�����ʽ���뵽$filename��
if ( $rdname -eq "" )
{ 
   $filename=$dmname
 }
else 
  {
    $filename=$rdname+"."+$dmname 
  }
   set-content -value "####################  prid=$id  "  -path "D:\Program Files\Apache Group\Apache2\conf.d\$filename.conf"
   add-content -value "<VirtualHost *:80>   " -path "D:\Program Files\Apache Group\Apache2\conf.d\$filename.conf"
   add-content -value "    servername  $filename "  -path  "D:\Program Files\Apache Group\Apache2\conf.d\$filename.conf"
   add-content -value "    DocumentRoot d:\temp   " -path "D:\Program Files\Apache Group\Apache2\conf.d\$filename.conf"
   add-content -value "    DirectoryIndex index.htm "  -path "D:\Program Files\Apache Group\Apache2\conf.d\$filename.conf"
   add-content -value "    Redirect / http://$address "  -path  "D:\Program Files\Apache Group\Apache2\conf.d\$filename.conf"
   add-content -value "</VirtualHost> "  -path "D:\Program Files\Apache Group\Apache2\conf.d\$filename.conf"  

#�ٴ�ִ��һ��sql��䣬���¼�¼
$SqlCmd.CommandText="update option set A=1 ,B = 1 where prid=$id"

$SqlCmd.executenonquery()  

}
$SqlConnection.Close()