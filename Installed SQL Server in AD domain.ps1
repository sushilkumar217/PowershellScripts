 #Prerequisite
 #Import-Module ServerManager
#Add-WindowsFeature RSAT-AD-PowerShell
$domain = "<Your Domain Name>" 
$computers=Get-ADComputer -LDAPFilter '(Description=*sql*)' -Server $domain -Property Name,DNSHostName,Description |Select -Property Name,DNSHostName,Description,Enabled,LastLogonDate 
$failedserver=''
$arr = [System.Collections.ArrayList]@()


function Invoke-SQL {
    param(
        [string] $dataSource ,
        [string] $database = "master",
        [string] $sqlCommand = $(throw "Please specify a query.")
      )

    $connectionString = "Data Source=$dataSource; " +
            "Integrated Security=SSPI; " +
            "Initial Catalog=$database"

    $connection = new-object system.data.SqlClient.SQLConnection($connectionString)
    $command = new-object system.data.sqlclient.sqlcommand($sqlCommand,$connection)
    $connection.Open()
    
    $adapter = New-Object System.Data.sqlclient.sqlDataAdapter $command
    $dataset = New-Object System.Data.DataSet
    $adapter.Fill($dataSet) | Out-Null
    
    $connection.Close()
    $dataSet.Tables

}
foreach($computer in $computers)
{
try{

(Invoke-Command -ComputerName $computer.DNSHostName -ErrorAction SilentlyContinue  -ScriptBlock {


function Invoke-SQL {
    param(
        [string] $dataSource ,
        [string] $database = "master",
        [string] $sqlCommand = $(throw "Please specify a query.")
      )

    $connectionString = "Data Source=$dataSource; " +
            "Integrated Security=SSPI; " +
            "Initial Catalog=$database"

    $connection = new-object system.data.SqlClient.SQLConnection($connectionString)
    $command = new-object system.data.sqlclient.sqlcommand($sqlCommand,$connection)
    $connection.Open()
    
    $adapter = New-Object System.Data.sqlclient.sqlDataAdapter $command
    $dataset = New-Object System.Data.DataSet
    $adapter.Fill($dataSet) | Out-Null
    
    $connection.Close()
    $dataSet.Tables

}
$instances = (Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Microsoft SQL Server').InstalledInstances 

foreach($sql in $instances)

{


    if ($sql -eq 'MSSQLSERVER')
    {
        $server="localhost"
    }
    else{
        $server="localhost\$sql"
    }

    Invoke-SQL -dataSource $server -Database  master -sqlCommand "SELECT @@SERVERNAME Server_name, CASE 
     WHEN CONVERT(VARCHAR(128), SERVERPROPERTY ('productversion')) like '8%' THEN 'SQL2000'
     WHEN CONVERT(VARCHAR(128), SERVERPROPERTY ('productversion')) like '9%' THEN 'SQL2005'
     WHEN CONVERT(VARCHAR(128), SERVERPROPERTY ('productversion')) like '10.0%' THEN 'SQL2008'
     WHEN CONVERT(VARCHAR(128), SERVERPROPERTY ('productversion')) like '10.5%' THEN 'SQL2008 R2'
     WHEN CONVERT(VARCHAR(128), SERVERPROPERTY ('productversion')) like '11%' THEN 'SQL2012'
     WHEN CONVERT(VARCHAR(128), SERVERPROPERTY ('productversion')) like '12%' THEN 'SQL2014'
     WHEN CONVERT(VARCHAR(128), SERVERPROPERTY ('productversion')) like '13%' THEN 'SQL2016'     
     WHEN CONVERT(VARCHAR(128), SERVERPROPERTY ('productversion')) like '14%' THEN 'SQL2017' 
     WHEN CONVERT(VARCHAR(128), SERVERPROPERTY ('productversion')) like '15%' THEN 'SQL2019' 
     WHEN CONVERT(VARCHAR(128), SERVERPROPERTY ('productversion')) like '16%' THEN 'SQL2022' 
     ELSE 'unknown'
  END AS MajorVersion , SERVERPROPERTY ('productlevel') productlevel, SERVERPROPERTY ('edition') edition"  

}
 } |Format-Table -HideTableHeaders|out-string).trim() |Out-File -FilePath B:\serverlist.csv -Append
  


  }
  catch
  {

  $arr.add($computer.DNSHostName)

}
}
