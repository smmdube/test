/* 
   20170427 - SD
   MS SQL Check Backups Database and/or Logs
*/
--Set Variables, read these and apply changes if needed
DECLARE @Type        VARCHAR(20)    = 'D'            -- Backup Type     ;   D=database OR L=Log OR 'B' for Both
DECLARE @Day         DATETIME       = GETDATE() - 1     -- Days to go back ;   1[+] 

-- Other variable needed
DECLARE @List        TABLE (ID VARCHAR(10))       -- temp table to hold field for database and logs
--incompete - DECLARE @Name        TABLE (name VARCHAR(100))    -- Pick a database



-- Set up for Both logs and database Files, this builds the field for IN
IF @TYPE IN (N'B')
   INSERT INTO @list SELECT ('L')
   INSERT INTO @list SELECT ('D');
--END SETUP
---------------------------------------------------------------------------------------------------------
SELECT 
  SERVER                =  CONVERT(CHAR(100),SERVERPROPERTY('Servername'))
 ,Database_Name         = msdb.dbo.backupset.database_name
 ,Backup_Start_Date     =  CONVERT(VARCHAR(16), msdb.dbo.backupset.backup_start_date,  120) 
 ,Backup_Finish_Date    = CONVERT(VARCHAR(16), msdb.dbo.backupset.backup_finish_date, 120) 
 ,Backup_Type           = CASE msdb..backupset.type
                            WHEN 'D'
                             THEN 'Database'
                            WHEN 'L'
                             THEN 'Log'
                            END
 ,Backup_Size_K         = msdb.dbo.backupset.backup_size
 ,Backup_Size_G         = CAST(msdb.dbo.backupset.backup_size / 1024 / 1024 / 1024 AS DECIMAL(16,2))
 ,Logical_Name          = msdb.dbo.backupmediafamily.logical_device_name
 ,Physical_Name         = msdb.dbo.backupmediafamily.physical_device_name
 ,Backupset_name        = msdb.dbo.backupset.NAME AS backupset_name
 ,Description           = msdb.dbo.backupset.description
FROM msdb.dbo.backupmediafamily
INNER JOIN msdb.dbo.backupset ON msdb.dbo.backupmediafamily.media_set_id = msdb.dbo.backupset.media_set_id
WHERE msdb..backupset.type IN   (select ID from  @list  )                           -- <--  Backup Type here
  AND msdb.dbo.backupset.database_name LIKE '%PROD'
  AND CONVERT(datetime, msdb.dbo.backupset.backup_start_date, 102) >= @DAY          -- <--  DAYS goes here
ORDER BY msdb.dbo.backupset.database_name
         ,msdb.dbo.backupset.backup_finish_date
