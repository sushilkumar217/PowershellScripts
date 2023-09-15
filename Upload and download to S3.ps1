 
#upload to S3 
$starttime= get-date
$starttime
$files = get-childitem -Path "B:\Backups"

foreach($file in $files)
{
    $file.fullname
    Write-S3Object -BucketName 'sushil-nvme-test2' -File $file.fullname
}

$endtime= get-date
$endtime



#download From S3
$starttime= get-date
$starttime
$files = Get-S3Object -BucketName sushil-nvme-test2 -Prefix "test"

foreach($file in $files)
{
    $file.key
    Read-S3Object -BucketName "sushil-nvme-test2" -key $file.key -File "B:\Backup\$($file.key)"
}

$endtime= get-date
$endtime

 
