# import the module 
#Import-Module C:\Github\jpomfret\dbatools\dbatools.psd1 -Force
Get-Module dbatools -ListAvailable

Import-Module dbatools

Write-Output 'starting'


# smo defaults
Set-DbatoolsConfig -FullName sql.connection.encrypt -Value optional
Set-DbatoolsConfig -FullName sql.connection.trustcert -Value $true

# make sure services are up
Get-Service MSSQLSERVER, SQLSERVERAGENT -ComputerName sql1,sql2 | Start-Service

# tear down any repl
# remove subscriptions
$sub = @{
    SqlInstance           = 'sql1'
    Database              = 'AdventureWorksLT2022'
    SubscriptionDatabase  = 'AdventureWorksLT2022'
    SubscriberSqlInstance = 'sql2'
    PublicationName       = 'testPub'
}
Remove-DbaReplSubscription @sub

$sub = @{
    SqlInstance           = 'sql1'
    Database              = 'AdventureWorksLT2022'
    SubscriptionDatabase  = 'AdventureWorksLT2022Merge'
    SubscriberSqlInstance = 'sql2'
    PublicationName       = 'Mergey'
}
Remove-DbaReplSubscription @sub

$sub = @{
    SqlInstance           = 'sql1'
    Database              = 'AdventureWorksLT2022'
    SubscriptionDatabase  = 'AdventureWorksLT2022Snap'
    SubscriberSqlInstance = 'sql2'
    PublicationName       = 'snappy'
}
Remove-DbaReplSubscription @sub

# remove an article
$article = @{
    SqlInstance = 'sql1'
    Database    = 'AdventureWorksLT2022'
    Publication = 'testpub'
    Schema      = 'salesLT'
    Name        = 'customer'
}
Remove-DbaReplArticle @article

# remove an article
$article = @{
    SqlInstance = 'sql1'
    Database    = 'AdventureWorksLT2022'
    Publication = 'Mergey'
    Schema      = 'salesLT'
    Name        = 'product'
}
Remove-DbaReplArticle @article

# remove an article
$article = @{
    SqlInstance = 'sql1'
    Database    = 'AdventureWorksLT2022'
    Publication = 'snappy'
    Schema      = 'salesLT'
    Name        = 'address'
}
Remove-DbaReplArticle @article

## remove publications
$pub = @{
    SqlInstance = 'sql1'
    Database    = 'AdventureWorksLT2022'
    Name        = 'TestPub'
    Confirm     = $false
}
Remove-DbaReplPublication @pub

$pub = @{
    SqlInstance = 'sql1'
    Database    = 'AdventureWorksLT2022'
    Name        = 'Snappy'
    Confirm     = $false
}
Remove-DbaReplPublication @pub

$pub = @{
    SqlInstance = 'sql1'
    Database    = 'AdventureWorksLT2022'
    Name        = 'Mergey'
    Confirm     = $false
}
Remove-DbaReplPublication @pub


# disable publishing 
Disable-DbaReplPublishing -SqlInstance sql1 -force

# disable distribution
Disable-DbaReplDistributor -SqlInstance  sql1

# remove databases on sql2
Get-DbaDatabase -SqlInstance sql2 -ExcludeSystem -ExcludeDatabase ReportServer, ReportServerTempDB | 
Remove-DbaDatabase -Confirm:$false 

# run the tests
Invoke-Pester .\demos\tests\demo.tests.ps1 -Output Detailed

# reset config
# smo defaults
Set-DbatoolsConfig -FullName sql.connection.encrypt -Value mandatory
Set-DbatoolsConfig -FullName sql.connection.trustcert -Value $false

Remove-Module dbatools