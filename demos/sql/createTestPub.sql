-- Enabling the replication database
use master
exec sp_replicationdboption
    @dbname = N'Northwind',
    @optname = N'publish',
    @value = N'true'
GO

exec [Northwind].sys.sp_addlogreader_agent
    @job_login = null,
    @job_password = null,
    @publisher_security_mode = 1
GO
-- Enabling the replication database
use master
exec sp_replicationdboption
    @dbname = N'Northwind',
    @optname = N'merge publish',
    @value = N'true'
GO

-- Adding the transactional publication
use [Northwind]
exec sp_addpublication
    @publication = N'testPub',
    @description = N'',
    @sync_method = N'native',
    @retention = 0,
    @allow_push = N'true',
    @allow_pull = N'false',
    @allow_anonymous = N'false',
    @enabled_for_internet = N'false',
    @snapshot_in_defaultfolder = N'true',
    @compress_snapshot = N'false',
    @ftp_port = 21,
    @ftp_login = N'anonymous',
    @allow_subscription_copy = N'false',
    @add_to_active_directory = N'false',
    @repl_freq = N'continuous',
    @status = N'active',
    @independent_agent = N'false',
    @immediate_sync = N'false',
    @allow_sync_tran = N'false',
    @autogen_sync_procs = N'false',
    @allow_queued_tran = N'false',
    @allow_dts = N'false',
    @replicate_ddl = 1,
    @allow_initialize_from_backup = N'false',
    @enabled_for_p2p = N'false',
    @enabled_for_het_sub = N'false'
GO


exec sp_addpublication_snapshot
    @publication = N'testPub',
    @frequency_type = 4,
    @frequency_interval = 1,
    @frequency_relative_interval = 1,
    @frequency_recurrence_factor = 0,
    @frequency_subday = 8,
    @frequency_subday_interval = 1,
    @active_start_time_of_day = 0,
    @active_end_time_of_day = 235959,
    @active_start_date = 0,
    @active_end_date = 0,
    @job_login = null,
    @job_password = null,
    @publisher_security_mode = 1

exec sp_grant_publication_access @publication = N'testPub',
    @login = N'sa'
GO

exec sp_grant_publication_access @publication = N'testPub',
    @login = N'NT AUTHORITY\NETWORK SERVICE'
GO

exec sp_grant_publication_access @publication = N'testPub',
    @login = N'BUILTIN\Administrators'
GO

exec sp_grant_publication_access @publication = N'testPub',
    @login = N'sqladmin'
GO

exec sp_grant_publication_access @publication = N'testPub',
    @login = N'distributor_admin'
GO

-- Adding the transactional articles
use [Northwind]
exec sp_addarticle
    @publication = N'testPub',
    @article = N'Customers',
    @source_owner = N'dbo',
    @source_object = N'Customers',
    @type = N'logbased',
    @description = N'',
    @creation_script = N'',
    @pre_creation_cmd = N'drop',
    @schema_option = 0x0000000000030077,
    @identityrangemanagementoption = N'none',
    @destination_table = N'Customers',
    @destination_owner = N'dbo',
    @status = 16,
    @vertical_partition = N'false',
    @ins_cmd = N'CALL [dbo].[sp_MSins_dboCustomers]',
    @del_cmd = N'CALL [dbo].[sp_MSdel_dboCustomers]',
    @upd_cmd = N'SCALL [dbo].[sp_MSupd_dboCustomers]',
    @filter_clause = N'City = ''Dublin'''

-- Adding the article filter
exec sp_articlefilter
    @publication = N'testPub',
    @article = N'Customers',
    @filter_name = N'FLTR_Customers_1__79',
    @filter_clause = N'City = ''Dublin''',
    @force_invalidate_snapshot = 1,
    @force_reinit_subscription = 1

-- Adding the article synchronization object
exec sp_articleview
    @publication = N'testPub',
    @article = N'Customers',
    @view_name = N'SYNC_Customers_1__79',
    @filter_clause = N'City = ''Dublin''',
    @force_invalidate_snapshot = 1,
    @force_reinit_subscription = 1
GO

-- Adding the transactional subscriptions
use [Northwind]
exec sp_addsubscription
    @publication = N'testPub',
    @subscriber = N'MSSQL2',
    @destination_db = N'Northwind',
    @subscription_type = N'Push',
    @sync_type = N'automatic',
    @article = N'all',
    @update_mode = N'read only',
    @subscriber_type = 0

exec sp_addpushsubscription_agent
    @publication = N'testPub',
    @subscriber = N'MSSQL2',
    @subscriber_db = N'Northwind',
    @job_login = null,
    @job_password = null,
    @subscriber_security_mode = 0,
    @subscriber_login = N'sqladmin',
    @subscriber_password = null,
    @frequency_type = 64,
    @frequency_interval = 1,
    @frequency_relative_interval = 1,
    @frequency_recurrence_factor = 0,
    @frequency_subday = 4,
    @frequency_subday_interval = 5,
    @active_start_time_of_day = 0,
    @active_end_time_of_day = 235959,
    @active_start_date = 0,
    @active_end_date = 0,
    @dts_package_location = N'Distributor'
GO

