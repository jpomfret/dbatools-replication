# import the module 
Import-Module C:\Github\jpomfret\dbatools\dbatools.psd1 -Force

Write-Output 'starting'


# smo defaults
Set-DbatoolsConfig -FullName sql.connection.encrypt -Value optional
Set-DbatoolsConfig -FullName sql.connection.trustcert -Value $true

# make sure services are up
Get-Service MSSQLSERVER, SQLSERVERAGENT -ComputerName sql2017,sql2019,sql2016 | Start-Service

# tear down any repl
# remove subscriptions
$sub = @{
    SqlInstance           = 'sql2017'
    Database              = 'AdventureWorksLT2017'
    SubscriptionDatabase  = 'AdventureWorksLT2017'
    SubscriberSqlInstance = 'sql2019'
    PublicationName       = 'testPub'
}
Remove-DbaReplSubscription @sub

$sub = @{
    SqlInstance           = 'sql2017'
    Database              = 'AdventureWorksLT2017'
    SubscriptionDatabase  = 'AdventureWorksLT2017Merge'
    SubscriberSqlInstance = 'sql2019'
    PublicationName       = 'Mergey'
}
Remove-DbaReplSubscription @sub

$sub = @{
    SqlInstance           = 'sql2017'
    Database              = 'AdventureWorksLT2017'
    SubscriptionDatabase  = 'AdventureWorksLT2017Snap'
    SubscriberSqlInstance = 'sql2019'
    PublicationName       = 'snappy'
}
Remove-DbaReplSubscription @sub

# remove an article
$article = @{
    SqlInstance = 'sql2017'
    Database    = 'AdventureWorksLT2017'
    Publication = 'testpub'
    Schema      = 'salesLT'
    Name        = 'customer'
}
Remove-DbaReplArticle @article

# remove an article
$article = @{
    SqlInstance = 'sql2017'
    Database    = 'AdventureWorksLT2017'
    Publication = 'Mergey'
    Schema      = 'salesLT'
    Name        = 'product'
}
Remove-DbaReplArticle @article

# remove an article
$article = @{
    SqlInstance = 'sql2017'
    Database    = 'AdventureWorksLT2017'
    Publication = 'snappy'
    Schema      = 'salesLT'
    Name        = 'address'
}
Remove-DbaReplArticle @article

## remove publications
$pub = @{
    SqlInstance = 'sql2017'
    Database    = 'AdventureWorksLT2017'
    Name        = 'TestPub'
    Confirm     = $false
}
Remove-DbaReplPublication @pub

$pub = @{
    SqlInstance = 'sql2017'
    Database    = 'AdventureWorksLT2017'
    Name        = 'Snappy'
    Confirm     = $false
}
Remove-DbaReplPublication @pub

$pub = @{
    SqlInstance = 'sql2017'
    Database    = 'AdventureWorksLT2017'
    Name        = 'Mergey'
    Confirm     = $false
}
Remove-DbaReplPublication @pub


# disable publishing 
Disable-DbaReplPublishing -SqlInstance sql2017 -force

# disable distribution
Disable-DbaReplDistributor -SqlInstance  sql2017

# remove databases on SQL2019
Get-DbaDatabase -SqlInstance sql2019 -ExcludeSystem -ExcludeDatabase ReportServer, ReportServerTempDB | 
Remove-DbaDatabase -Confirm:$false 

# run the tests
Invoke-Pester .\demos\tests\* -Output Detailed

# reset config
# smo defaults
Set-DbatoolsConfig -FullName sql.connection.encrypt -Value mandatory
Set-DbatoolsConfig -FullName sql.connection.trustcert -Value $false

Remove-Module dbatools