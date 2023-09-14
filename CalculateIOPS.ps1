 

    # Check if the disk has performance data (may not be available for all disks)
    while(1 -eq 1)


{       
        $diskPerf = Get-Counter -Counter "\PhysicalDisk(2 e:)\Disk Read Bytes/sec","\PhysicalDisk(2 e:)\Disk Write Bytes/sec","\PhysicalDisk(2 e:)\Avg. Disk Bytes/Read","\PhysicalDisk(2 e:)\Avg. Disk Bytes/Write","\PhysicalDisk(2 e:)\Disk Reads/sec","\PhysicalDisk(2 e:)\Disk Writes/sec"
        
        $DiskReads = ($diskPerf.CounterSamples | Where-Object { $_.Path -like "*\PhysicalDisk(2 e:)\Disk Read Bytes/sec" }).CookedValue
        $DiskWrites = ($diskPerf.CounterSamples | Where-Object { $_.Path -like "*\PhysicalDisk(2 e:)\Disk Write Bytes/sec" }).CookedValue
        $avgread = ($diskPerf.CounterSamples | Where-Object { $_.Path -like "*\PhysicalDisk(2 e:)\Avg. Disk Bytes/Read" }).CookedValue
        $avgwrites = ($diskPerf.CounterSamples | Where-Object { $_.Path -like "*\PhysicalDisk(2 e:)\Avg. Disk Bytes/Write" }).CookedValue
        $readthroughput = ($diskPerf.CounterSamples | Where-Object { $_.Path -like "*\PhysicalDisk(2 e:)\Disk Reads/sec" }).CookedValue
        $writethroughput = ($diskPerf.CounterSamples | Where-Object { $_.Path -like "*\PhysicalDisk(2 e:)\Disk Writes/sec" }).CookedValue

        if ($DiskReads -eq 0){$DiskReads= 1 }
        if ($DiskWrites -eq 0){$DiskWrites= 1 }
        if ($avgread -eq 0){$avgread= 1 }
        if ($avgwrites -eq 0){$avgwrites= 1 }
        if ($readthroughput -eq 0){$DiskReads= 1 }
        if ($writethroughput -eq 0){$DiskReads= 1 }

        $throughput = $DiskReads  + $DiskWrites
        $readIOPS =  $DiskReads / $avgread
        $writeIOPS = $DiskWrites / $avgwrites
        $totalIOPS =  $readIOPS + $writeIOPS 
          $query="insert into dbo.IOPS(drive, counter, value) select 'E:\-NVME','READIOPS',$readIOPS"
        invoke-sqlcmd -ServerInstance "EC2AMAZ-3B2OB6A\mssqlSERVER" -Database db1  -Query $query


        
        $query="insert into dbo.IOPS(drive, counter, value) select 'E:\-NVME','WRITEIOPS',$writeIOPS"
        invoke-sqlcmd -ServerInstance "EC2AMAZ-3B2OB6A\mssqlSERVER" -Database db1  -Query $query

        

        $query="insert into dbo.IOPS(drive, counter, value) select 'E:\-NVME','TOTALIOPS',$totalIOPS "
        invoke-sqlcmd -ServerInstance "EC2AMAZ-3B2OB6A\mssqlSERVER" -Database db1  -Query $query


        $query="insert into dbo.IOPS(drive, counter, value) select 'E:\-NVME','Throughput',$throughput "
        invoke-sqlcmd -ServerInstance "EC2AMAZ-3B2OB6A\mssqlSERVER" -Database db1  -Query $query


     
        $diskPerf = Get-Counter -Counter "\PhysicalDisk(1 s:)\Disk Read Bytes/sec","\PhysicalDisk(1 s:)\Disk Write Bytes/sec","\PhysicalDisk(1 s:)\Avg. Disk Bytes/Read","\PhysicalDisk(1 s:)\Avg. Disk Bytes/Write","\PhysicalDisk(1 s:)\Disk Reads/sec","\PhysicalDisk(1 s:)\Disk Writes/sec"
        
        $DiskReads = ($diskPerf.CounterSamples | Where-Object { $_.Path -like "*\PhysicalDisk(1 s:)\Disk Read Bytes/sec" }).CookedValue
        $DiskWrites = ($diskPerf.CounterSamples | Where-Object { $_.Path -like "*\PhysicalDisk(1 s:)\Disk Write Bytes/sec" }).CookedValue
        $avgread = ($diskPerf.CounterSamples | Where-Object { $_.Path -like "*\PhysicalDisk(1 s:)\Avg. Disk Bytes/Read" }).CookedValue
        $avgwrites = ($diskPerf.CounterSamples | Where-Object { $_.Path -like "*\PhysicalDisk(1 s:)\Avg. Disk Bytes/Write" }).CookedValue
        $readthroughput = ($diskPerf.CounterSamples | Where-Object { $_.Path -like "*\PhysicalDisk(1 s:)\Disk Reads/sec" }).CookedValue
        $writethroughput = ($diskPerf.CounterSamples | Where-Object { $_.Path -like "*\PhysicalDisk(1 s:)\Disk Writes/sec" }).CookedValue
                if ($DiskReads -eq 0){$DiskReads= 1 }
        if ($DiskWrites -eq 0){$DiskWrites= 1 }
        if ($avgread -eq 0){$avgread= 1 }
        if ($avgwrites -eq 0){$avgwrites= 1 }
        if ($readthroughput -eq 0){$DiskReads= 1 }
        if ($writethroughput -eq 0){$DiskReads= 1 }
        $throughput = $DiskReads  + $DiskWrites
        $readIOPS =  $DiskReads / $avgread
        $writeIOPS = $DiskWrites / $avgwrites
        $totalIOPS =  $readIOPS + $writeIOPS 
          $query="insert into dbo.IOPS(drive, counter, value) select 'S:\-EBS','READIOPS',$readIOPS"
        invoke-sqlcmd -ServerInstance "EC2AMAZ-3B2OB6A\mssqlSERVER" -Database db1  -Query $query


        
        $query="insert into dbo.IOPS(drive, counter, value) select 'S:\-EBS','WRITEIOPS',$writeIOPS"
        invoke-sqlcmd -ServerInstance "EC2AMAZ-3B2OB6A\mssqlSERVER" -Database db1  -Query $query

        

        $query="insert into dbo.IOPS(drive, counter, value) select 'S:\-EBS','TOTALIOPS',$totalIOPS "
        invoke-sqlcmd -ServerInstance "EC2AMAZ-3B2OB6A\mssqlSERVER" -Database db1  -Query $query


        $query="insert into dbo.IOPS(drive, counter, value) select 'S:\-EBS','Throughput',$throughput "
        invoke-sqlcmd -ServerInstance "EC2AMAZ-3B2OB6A\mssqlSERVER" -Database db1  -Query $query


        Start-Sleep -Seconds 5
} 
