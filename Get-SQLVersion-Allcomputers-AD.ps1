#This PowerShell script is designed to gather information about Microsoft SQL Server instances installed on a set of remote computers. 
#It uses Active Directory to filter computer objects based on a specific description containing the term "sql". 
#For each matching computer, the script attempts to execute a series of commands remotely to retrieve information about the SQL Server
#instances installed on them. The script utilizes PowerShell's remoting capabilities to execute commands on the remote computers.

#This script requires Active Directory access, permissions to execute commands remotely on target computers, and firewall settings that allow PowerShell remoting.
#Make sure to test the script in a controlled environment before running it on production systems.
#This script might need modifications to work with different network configurations or PowerShell execution policies.

#authour : Sushil Kumar
#Date : 14/08/2023

$computers=Get-ADComputer -LDAPFilter '(Description=*sql*)' -Property Name,DNSHostName,Description |Select -Property Name,DNSHostName,Description,Enabled,LastLogonDate 
$failedserver=''

foreach($computer in $computers)
{
try{
Invoke-Command -ComputerName $computer.DNSHostName -ErrorAction SilentlyContinue -ScriptBlock {
$instances = (Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Microsoft SQL Server').InstalledInstances 

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
 }
  }
  catch
  {
  $failedserver +=$computer.DNSHostName

}
}