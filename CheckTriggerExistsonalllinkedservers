$ErrorActionPreference = 'SilentlyContinue'
$CentralServer = "monitoringserver";
$ConnectionTimeout = 60;
$db='monitoringdb'
$sql_get_server_list = "
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

SELECT FriendlyName as server
  FROM $db.dbo.monitoringtable
 WHERE IsActive = 1

   ";


$checkTrigger =@"
DECLARE @triggerexits bit
   DECLARE @triggerenabled bit 
   DECLARE @server  NVARCHAR(20)
   
   if exists(SELECT 1 from sys.server_triggers WHERE name ='$trigger')
   BEGIN
   SET @triggerexits =1
   SELECT @triggerenabled = Case when is_disabled=0 then 1 else 0 end from sys.server_triggers WHERE name ='$trigger'
   
   END
   ELSE
   BEGIN
   SET @triggerexits =0
   SET @triggerenabled =0
  
   END

   SELECT @@SERVERNAME as [Server],@triggerexits as [IsTriggerExists],@triggerenabled [IsTriggeredEnabled]

"@
$results=@()
$servers=invoke-sqlcmd  -ServerInstance "$centralServer" -Database master -Query $sql_get_server_list
foreach ($server in $servers)
{
 $result = invoke-sqlcmd  -ServerInstance $server.server -Database master -Query $checkTrigger 
$Results += [PSCustomObject] @{
 Server = $result.Server
 IsTriggeredEnabled = $result.IsTriggeredEnabled
  IsTriggerExists = $result.IsTriggerExists

 }
}
$Results |Sort-Object HistProcessLastEntry
