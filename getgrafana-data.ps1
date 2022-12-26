# Set your Grafana API key and dashboard ID
$apiKey = "<API KEY>"


#url to get all folders and files
$url = "http://<host>:<port>/api/search?query=%"

#get all folder and dashboards
$dashboards = Invoke-RestMethod -Uri $url -Method Get -Headers $Headers -ContentType ‘application/json’;

# Set the HTTP headers, including the Authorization header with the API key
$headers = @{
    "Authorization" = "Bearer $apiKey"
}

foreach ($title in $dashboards)
{
#get dashboard UID
$dashboardId = $title.uid

#get dashboard name
$dashboardname = $title.title

# Set the URL for the Grafana API
$url = "http://<host>:<port>/api/dashboards/uid/$dashboardId"

#Send a GET request to the Grafana API to retrieve the dashboard
$dashboard = Invoke-RestMethod -Method Get -Uri $url -Headers $headers -UseBasicParsing 

# Save the dashboard as a JSON file
$json = $dashboard.dashboard.panels | ConvertTo-Json 

$dashboardId
$dashboardname
$url
$json
$sql = "
INSERT INTO <db_name>..grafana_data(dashboard_id,dashboard_name,url,json_data)
SELECT '$dashboardId','$dashboardname','$url','$json'
"

Invoke-Sqlcmd -ServerInstance <MonitorDatabaseServer> -Database master -Query $sql
}
